module Toygun
  module ModelAttributes
    class AttrCodec < RecordCodec
      def dump_one(o)
        if o.class < Sequel::Model
          {"Model": [ o.class, o[o.primary_key]] }
        else
          super(o)
        end
      end

      def parse_one(o)
        if Hash === o && o.size == 1
          k, i = o.entries.first
          if k == "Model"
            klass, pk = i
            klass = klass.split(/::/).inject(Kernel) {|kl, sub| kl.const_get(sub)}
            if klass < Sequel::Model
              klass[pk]
            else
              raise "what #{k} #{k.class} #{klass} #{klass.class}"
            end
          else
            super(o)
          end
        else
          super(o)
        end
      end
    end

    Codec = AttrCodec.new

    def self.apply(name, *args, &block)
      name.plugin :composition
      name.composition :attrs,
        :composer => (proc do
          Codec.parse(self.raw_attrs)
        end),
        :decomposer => (proc do
          if o = compositions[:attrs]
            self.raw_attrs = Codec.dump(attrs)
          else
            self.raw_attrs = {}
          end
        end)
    end

    module ClassMethods
      def fields
        if superclass.respond_to?(:fields)
          [].concat(superclass.fields).concat(self.class_fields)
        else
          @fields ||= []
        end
      end

      def class_fields
        @fields ||= []
      end

      def field(name)
        name = name.to_sym
        raise "defined" if fields.include?(name)
        class_fields << name
        self.class_eval do
          define_method("#{name}") do
            self.attrs[name]
          end

          define_method("#{name}=") do |value|
            self.modified! :attrs
            self.attrs[name] = value
          end
        end
      end
    end
  end
end

