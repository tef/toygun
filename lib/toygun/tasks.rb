module Toygun
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

    one_to_many :transitions, key: :task_uuid, primary_key: :uuid, order: Sequel.desc(:step), class: TaskTransition

    include State::InstanceMethods

    plugin ModelAttributes

    def self.state name, &block
      task_states[name] = block
      self
    end

    def self.task_states
      @task_states ||= {}
    end

    def self.has_state?(new_state)
      State.builtin_states.include?(new_state) || self.task_states.include?(new_state)
    end

    def_dataset_method :active do
        exclude(state: State::STOP)
    end

    def start(**opts)
      if state == State::NEW
        transition self.class.task_states.first[0], opts
     end
    end

    def tick
      return if state == State::STOP
      raise State::Panic if state == State::PANIC
      start if state == State::NEW

      if block = self.class.task_states[state]
        instance_eval &block
      else
        raise State::Missing, "Missing state defintion for #{state} in #{self.class}"
      end
    end


    def self.find_recent_for(resource)
      self.where(resource_uuid: resource.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
    end

    def self.find_or_create_for(resource)
      self.db.transaction do
        if Locks.pg_try_advisory_xact_lock(self, resource.uuid)
          task = self.where(resource_uuid: resource.uuid).order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(resource_uuid: resource.uuid) do |t|
              t.state = State::STOP
              t.attrs = {}
            end
          end
          task
        end
      end
    end

    def self.start_for(resource, **opts)
      db.transaction do
        if Locks.pg_try_advisory_xact_lock(self, resource.uuid)
          task = self.where(resource_uuid: resource.uuid).exclude(state: State::STOP).order_by(Sequel.desc(:created_at, nulls: :last)).first
          if task.nil?
            task = self.create(resource_uuid: resource.uuid) do |t|
              t.state = State::NEW
              t.attrs = opts
            end
          end
          task
        end
      end
    end

    def self.define_task_on(resource, name, &block)
      class_name = name.to_s.split(/_/).map{ |word| word.capitalize }.join('').sub("!","")
      resource_name = resource.to_s.split('::')[-1].split(/(?=[A-Z]+)/).map(&:downcase).join("_").to_sym

      resource.class_eval "class #{class_name} < #{self}; end"

      t = resource.const_get(class_name)

      t.class_eval do 
        many_to_one :resource, class: resource, key: :resource_uuid, primary_key: :uuid
        alias_method resource_name, :resource if resource_name != 'resource' 
      end

      t.class_eval &block

      resource.class_eval do
        define_method(name.to_s+"_task") do
          t.find_or_create_for(self)
        end

        def_dataset_method("#{name}_tasks") do
         t.where('resource_uuid in ?', self.select(:uuid))
        end

        define_method(name) do |**opts|
          task = t.start_for(self, **opts)
        end

        def_dataset_method("#{name}") do |**opts|
          all.each do |resource|
            t.start_for(resource, **opts)
          end
        end

        define_method(name.to_s+"_running?") do
          task = t.find_recent_for(self)
          task && task.running?
        end

        def_dataset_method("#{name}_running?") do
          t.where('foreign_uuid in ?', self.select(:uuid)).exclude(state: State::STOP).count > 0
        end
      end

      t
    end
  end
end
