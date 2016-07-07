module Toygun
  module State
    NEW = '__new__'.freeze
    STOP = '__stop__'.freeze
    PANIC = '__panic__'.freeze

    class Panic < StandardError; end
    class Missing < StandardError; end

    class Desynchronized < StandardError
       def initialize(opts)
         @uuid = opts.delete(:uuid)
         @expected = opts.delete(:expected)
         @actual = opts.delete(:actual)
       end

       def message
         "Expected stateful object #{@uuid} to be in #{@expected}; it has already transitioned to #{@actual}"
       end
    end
  end

  module Locks
    def self.pg_try_advisory_xact_lock(klass, key)
      lock_a, lock_b = [Zlib.crc32("#{klass.table_name}"),Zlib.crc32("#{key}")].pack('LL').unpack('ll')
      Task.db["SELECT pg_try_advisory_xact_lock(CAST(#{lock_a} as int),CAST(#{lock_b} as int))"].get
    end
  end

  module Subtasks
    module ClassMethods
      def task(name, &block)
        class_name = name.to_s.split(/_/).map{ |word| word.capitalize }.join('').sub("!","")
        parent_name = self.to_s.split('::')[-1].split(/(?=[A-Z]+)/).map(&:downcase).join("_").to_sym
        parent = self

        t = Task.define_task_on(self, class_name, &block)
        class_eval do
          define_method(name.to_s+"_task") do
            t.find_or_create_for(self)
          end
          define_method(name) do |**opts|
            task = t.start_for(self, **opts)
          end
          define_method(name.to_s+"_running?") do
            task = t.find_recent_for(self)
            task && task.running?
          end
        end
        t.class_eval do 
          many_to_one :parent, class: parent, key: :parent_uuid, primary_key: :uuid
          alias_method parent_name, :parent
        end
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
