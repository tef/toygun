module Toygun
  class TaskPanic < StandardError; end
  class MissingTaskState < StandardError; end

  class TaskTransition < Sequel::Model
    plugin :timestamps, update_on_create: true

    def_dataset_method :latest do
      order(:created_at.desc).first
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

    one_to_many :task_transitions, key: :task_uuid, primary_key: :uuid, order: Sequel.desc(:updated_at)

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

    def start(opts={})
      if state == "stop" || state == "panic"
        reset opts
      end
    end

    def reset(opts={})
      self.attrs = {}
      transition self.class.task_states.first[0], opts
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

    def transition(new_state, opts={})
      current_state = state
      raise MissingTaskState, new_state if !["panic", "stop"].include?(new_state) && !self.class.task_states[new_state]
      Toygun::Task.db.transaction do
        latest_state = task_transitions.first
        if latest_state.nil? || latest_state.to == current_state
          add_task_transition(from: current_state, to: new_state)
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
            t.find_or_create(foreign_uuid: self.uuid) {|task| task.state = "stop"; task.attrs = {} }
          end
          define_method(name) do |opts={}|
            task = t.find_or_create(foreign_uuid: self.uuid) {|task| task.state = "stop"; task.attrs = {}}
            task.start opts
          end
          define_method(name.to_s+"_running?") do
            task = t.find(foreign_uuid: self.uuid)
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

