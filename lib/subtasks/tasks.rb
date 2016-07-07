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
