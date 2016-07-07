module Toygun
  module Locks
    def self.pg_try_advisory_xact_lock(klass, key)
      lock_a, lock_b = [Zlib.crc32("#{klass.table_name}"),Zlib.crc32("#{key}")].pack('LL').unpack('ll')
      Task.db["SELECT pg_try_advisory_xact_lock(CAST(#{lock_a} as int),CAST(#{lock_b} as int))"].get
    end
  end

  module Subtasks
    module ClassMethods
      def def_task(name, &block)
        Task.define_task_on(self, name, &block)
      end
    end

    module InstanceMethods
      def run_active_tasks
        tasks_dataset.active.each do |t|
          # err handling
          t.tick
        end
      end
    end

    def self.included(base)
      base.one_to_many :tasks, class: 'Toygun::Task', key: :parent_uuid, primary_key: :uuid
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
