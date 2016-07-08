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

    def register(klass, codec)
      handlers[klass] = codec
    end

    def handlers
      @handlers ||= {}
    end

    class ModelHandler
      # codec.register Resource, ModelHandler.new(Resource)
      def initialize(klass)
        @klass = klass
      end

      def dump(obj, codec)
        o[o.primary_key]
      end

      def parse(key, codec)
        @klass[v]
      end
    end

    def dump_one(o)
      if handlers.include? o
        {o.name => handlers[o].dump(o, self)}
      elsif Symbol === o
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
        elsif handlers.include? k
          handlers[k].parse(v, self)
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
      raise "heck" if !self.handlers.include? o
      o = dump_one(o)
      raise "heck" if !(Hash === o)
      o.to_json
    end

    def parse_obj(string)
      json = JSON.parse(string)
      raise "heck" if !(Hash === o)
      o = parse_one(json)
      raise "heck" if !self.handlers.include? o
      o
    end
  end

  class RecordCodec < Codec
    def dump_hash(o)
      h = o.inject({}) {|h, (k,v)| h.merge(dump_field(k,v))}
      h.to_json
    end

    def dump_field(k,v)
      {k => dump_one(v)}
    end

    def parse_hash(string)
      json = JSON.parse(string)
      json.inject({}) {|h, (k,v)| h.merge(parse_field(k,v))}
    end

    def parse_field(k,v)
      {k => parse_one(v)}
    end
  end
end
