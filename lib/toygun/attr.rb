module Toygun
  module ModelAttributes
    def self.apply(name, *args, &block)
      name.plugin :composition
      name.composition :attrs,
        :composer => (proc do
          self.raw_attrs
        end),
        :decomposer => (proc do
          if o = compositions[:attrs]
            self.raw_attrs = attrs
          else
            self.raw_attrs = {}
          end
        end)
    end

    module ClassMethods
      def field(name)
        name = name.to_s
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

