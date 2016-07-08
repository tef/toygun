module Toygun
  module ModelAttributes
    def field(name)
      name = name.to_s
      self.class_eval do
        define_method("#{name}") do 
          self.attrs[name] 
        end

        define_method("#{name}=") do |value|
          self.attrs[name] = value
          self.modified! :attrs
          self.save_changes
        end
      end
    end
  end
end

