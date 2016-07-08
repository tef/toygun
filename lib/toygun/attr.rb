module Toygun
  module ModelAttributes
    def self.apply(name)
      # name.plugin composition
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

