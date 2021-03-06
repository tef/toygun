module Toygun
  module Subtasks
    module ClassMethods
      def def_task(name, &block)
        # define parent accessor
        Task.define_task_on(self, name, &block)
      end
    end

    module InstanceMethods
      def tick
        tasks_dataset.active.each do |t|
          # err handling
          t.tick
        end
      end
    end

    def self.included(base)
      base.one_to_many :tasks, class: 'Toygun::Task', key: :resource_uuid, primary_key: :uuid
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
