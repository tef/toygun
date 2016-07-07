module Toygun
  class TaskPanic < StandardError; end
  class MissingTaskState < StandardError; end

  class TaskTransition < Sequel::Model
    plugin :timestamps, update_on_create: true

    def_dataset_method :latest do
      order(:step.desc).first
    end

    def duration
      Time.now - created_at
    end
  end

  class DesynchronizedTaskStateException < StandardError
     def initialize(opts)
       @uuid = opts.delete(:uuid)
       @expected = opts.delete(:expected)
       @actual = opts.delete(:actual)
     end

     def message
       "Expected stateful object #{@uuid} to be in #{@expected}; it has already transitioned to #{@actual}"
     end
  end

  class Task < Sequel::Model
    plugin :single_table_inheritance, :name
    plugin :timestamps, update_on_create: true

    one_to_many :task_transitions, key: :task_uuid, primary_key: :uuid, order: Sequel.desc(:step)

    def_dataset_method :active do
      exclude(state: "stop")
    end

    def running?
      state != "stop"
    end

    def tick
      return if state == "stop"
      raise TaskPanic if state == "panic"

      if block = self.class.task_states[state]
        instance_eval &block
      else
        raise MissingTaskState, "Missing state defintion for #{state} in #{self.class}"
      end
    end

    def start(**opts)
      if state == "new"
        transition self.class.task_states.first[0], opts
      end
    end

    def stop
      if state != "stop"
        transition "stop"
      end
    end

    def panic(message: "Task panicked")
      transition "panic", {panic_message: message}
    end

    def panic?
      state == "panic"
    end

    def rewind(index)
      return if index < 1
      latest = task_transitions.first.created_at
      if last_known = task_transitions_dataset.where('created_at < ?', latest).order(Sequel.desc(:created_at)).limit(index).last
        transition last_known.to
      end
    end

    def transition(new_state, **opts)
      current_state = state
      raise MissingTaskState, new_state if !["panic", "stop"].include?(new_state) && !self.class.task_states[new_state]
      Toygun::Task.db.transaction do
        latest_state = task_transitions.first
        if latest_state.nil? || latest_state.to == current_state
          new_step = latest_state.nil? ? 0 : latest_state.step+1
          add_task_transition(from: current_state, to: new_state, step: new_step)
          self.attrs.update(opts)
          self.state = new_state
          self.save
        else
          raise DesynchronizedTaskStateException, uuid: uuid, expected: current_state, actual: latest_state.to
        end
      end
      reload
    end

    def self.state name, &block
      task_states[name] = block
      self
    end

    def self.task_states
      @task_states ||= {}
    end

    def self.define_task_on(inside, class_name, &block)
      inside.class_eval "class #{class_name} < #{self}; end"
      t = inside.const_get(class_name)
      t.class_eval &block
      t
    end

    def self.find_recent_for(parent)
      self.where(foreign_uuid: parent.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
    end

    def self.find_or_create_for(parent)
      self.db.transaction do
        if Subtasks.pg_try_advisory_xact_lock(self, parent.uuid)
          task = self.where(foreign_uuid: parent.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(foreign_uuid: parent.uuid) do |t|
              t.state = "stop"
              t.attrs = {}
            end
          end
          task
        end
      end
    end

    def self.start_for(parent, **opts)
      db.transaction do
        if Subtasks.pg_try_advisory_xact_lock(self, parent.uuid)
          task = self.where(foreign_uuid: parent.uuid).exclude(state: 'stop').order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(foreign_uuid: parent.uuid) do |t|
              t.state = "new"
              t.attrs = opts
            end
            task.start
          end
          task
        end
      end
    end
  end

  module Subtasks
    def self.pg_try_advisory_xact_lock(klass, key)
      lock_a, lock_b = [Zlib.crc32("#{klass.table_name}"),Zlib.crc32("#{key}")].pack('LL').unpack('ll')
      Task.db["SELECT pg_try_advisory_xact_lock(CAST(#{lock_a} as int),CAST(#{lock_b} as int))"].get
    end

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
        t.many_to_one parent_name, class: parent, key: :foreign_uuid, primary_key: :uuid
      end
    end

    module InstanceMethods
      def run_active_tasks
        tasks_dataset.active.each do |t|
          t.tick
        end
      end
    end

    def self.included(base)
      base.one_to_many :tasks, class: 'Toygun::Task', key: :foreign_uuid, primary_key: :uuid
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end

