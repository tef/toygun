require 'set'
require 'date'
require 'stringio'
require 'net/http'

module Toygun
  class Secret
    def initialize(tool, key_num, blob)
      @tool = tool
      @key_num = key_num
      @blob = blob
    end

    def decrypt(&block)
      raise if @tool != "fernet"
      key = Toygun.keychain.fetch(@key_num)
      v = Fernet.verifier(key, @blob)
      if v.valid?
        block.call(v.message)
      else
        raise "heck"
      end
    end

    def self.encrypt(message)
      num = Toygun.keychain.keys.max
      Secret.new("fernet", num, Fernet.generate(Toygun.keychain.fetch(num), message))
    end

    def dump
      {"Secret":[@tool, @key_num, @blob]}
    end

    def self.parse(v)
      Secret.new(v[0], v[1], v[2])
    end
  end

  class Codec
    CONTENT_TYPE = "application/decorated-json"

    class DecodeError < StandardError
    end
    class EncodeError < StandardError
    end

    def dump(o)
      dump_one(o)
    end

    def parse(o)
      parse_one(o)
    end

    def encrypt_one(o)
      Secret.encrypt(dump_one([o]).to_json)
    end

    def decrypt_one(o)
      return nil if o == nil
      o.decrypt do |m|
        return parse_one(JSON.parse(m).first)
      end
    end

    def dump_one(o)
      if Symbol === o
        {"Symbol" => o.to_s}
      elsif String === o
        o
      elsif Fixnum === o
        o
      elsif Float === o
        o
      elsif TrueClass === o
        o
      elsif FalseClass === o
        o
      elsif o.nil?
        o
      elsif Array === o
        o.map{|o| dump_one(o)}
      elsif Set === o
        {"Set" => o.map{|o| dump_one(o)}}
      elsif Hash === o
        {"Hash": o.inject({}) {|h, (k,v)| h[dump_one(k)] = dump_one(v); h} }
      elsif DateTime === o
        {"DateTime" => o.strftime("%FT%T.%NZ")}
      elsif Time === o
        {"Time" => o.strftime("%FT%T.%LZ")}
      elsif Secret === o
        o.dump
      else
        raise EncodeError, "unsupported #{o}"
      end
    end

    def parse_one(o)
      if String === o
        o
      elsif Fixnum === o
        o
      elsif Float === o
        o
      elsif TrueClass === o
        o
      elsif FalseClass === o
        o
      elsif o.nil?
        o
      elsif Array === o
        o.map {|o| parse_one(o)}
      elsif Hash === o && o.size == 1
        k, v = o.entries.first

        if k == "Hash"
          v.inject({}) {|h, (k,v)| h[parse_one(k)] = parse_one(v); h}
        elsif k == "DateTime"
          DateTime.strptime(v, "%FT%T.%L%Z")
        elsif k == "Time"
          Time.strptime(v, "%FT%T.%L%Z")
        elsif k == "Set"
          v.inject(Set.new) {|s, o| s.add(parse_one(o));s }
        elsif k == "Symbol"
          v.to_sym
        elsif k == "Secret"
          Secret.parse(v)
        else
          raise DecodeError, "special unsupported #{o}"
        end
      else
        raise DecodeError, "unsupported #{o} #{o.class}"
      end
    end
  end

  class ObjectCodec < Codec
    def dump_obj(o)
      o = dump_one(o)
      raise "heck" if !(Hash === o)
      o.to_json
    end

    def parse_obj(string)
      json = JSON.parse_one(string)
      raise "heck" if !(Hash === o)
      o = parse_one(json)
      o
    end
  end

  class RecordCodec < Codec
    def dump(o)
      h = o.inject({}) {|h, (k,v)| h.merge(dump_field(k,v))}
    end

    def dump_field(k,v)
      {k => dump_one(v)}
    end

    def parse(json)
      json.inject({}) {|h, (k,v)| h.merge(parse_field(k,v))}
    end

    def parse_field(k,v)
      {k.to_sym => parse_one(v)}
    end
  end
end
