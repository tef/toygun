module Toygun
  module State
    module InstanceMethods
      def running?
        state != STOP
      end

      def tick
        return if state == STOP
        raise Panic if state == PANIC

        if block = self.class.task_states[state]
          instance_eval &block
        else
          raise Missing, "Missing state defintion for #{state} in #{self.class}"
        end
      end

      def start(**opts)
        if state == NEW
          transition self.class.task_states.first[0], opts
        end
      end

      def stop
        if state != STOP
          transition STOP
        end
      end

      def panic(message: "Task panicked")
        transition PANIC, {panic_message: message}
      end

      def panic?
        state == PANIC
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
        raise Missing, new_state if ![PANIC, STOP].include?(new_state) && !self.class.task_states[new_state]
        Toygun::Task.db.transaction do
          latest_state = task_transitions.first
          if latest_state.nil? || latest_state.to == current_state
            new_step = latest_state.nil? ? 0 : latest_state.step+1
            add_task_transition(from: current_state, to: new_state, step: new_step)
            self.attrs.update(opts)
            self.state = new_state
            self.save
          else
            raise Desynchronized, uuid: uuid, expected: current_state, actual: latest_state.to
          end
        end
        reload
      end
    end

    module ClassMethods
      def state name, &block
        task_states[name] = block
        self
      end

      def task_states
        @task_states ||= {}
      end
    end
  end

  class TaskTransition < Sequel::Model
    plugin :timestamps, update_on_create: true

    def_dataset_method :latest do
      order(:step.desc).first
    end

    def duration
      Time.now - created_at
    end
  end

  class Task < Sequel::Model
    plugin :single_table_inheritance, :name
    plugin :timestamps, update_on_create: true

    one_to_many :task_transitions, key: :task_uuid, primary_key: :uuid, order: Sequel.desc(:step)

    include State::InstanceMethods
    extend State::ClassMethods

    def_dataset_method :active do
        exclude(state: State::STOP)
    end

    def self.find_recent_for(parent)
      self.where(parent_uuid: parent.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
    end

    def self.find_or_create_for(parent)
      self.db.transaction do
        if Locks.pg_try_advisory_xact_lock(self, parent.uuid)
          task = self.where(parent_uuid: parent.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(parent_uuid: parent.uuid) do |t|
              t.state = State::STOP
              t.attrs = {}
            end
          end
          task
        end
      end
    end

    def self.start_for(parent, **opts)
      db.transaction do
        if Locks.pg_try_advisory_xact_lock(self, parent.uuid)
          task = self.where(parent_uuid: parent.uuid).exclude(state: State::STOP).order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(parent_uuid: parent.uuid) do |t|
              t.state = State::NEW
              t.attrs = opts
            end
            task.start
          end
          task
        end
      end
    end

    def self.define_task_on(inside, class_name, &block)
      inside.class_eval "class #{class_name} < #{self}; end"
      t = inside.const_get(class_name)
      t.class_eval &block
      t
    end
  end
end
