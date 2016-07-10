require 'set'
require 'date'
require 'stringio'
require 'net/http'

module Toygun
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

  class JsonObjectCodec < Codec
    def dump_json(o)
      h = o.inject({}) {|h, (k,v)| h.merge(dump_field(k,v))}
    end

    def dump_field(k,v)
      {k => dump_one(v)}
    end

    def parse_json(json)
      json.inject({}) {|h, (k,v)| h.merge(parse_field(k,v))}
    end

    def parse_field(k,v)
      {k.to_sym => parse_one(v)}
    end
  end
end
