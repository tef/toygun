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
end