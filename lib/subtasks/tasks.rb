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

    def self.define_task_on(parent, name, &block)
      class_name = name.to_s.split(/_/).map{ |word| word.capitalize }.join('').sub("!","")
      parent_name = parent.to_s.split('::')[-1].split(/(?=[A-Z]+)/).map(&:downcase).join("_").to_sym

      parent.class_eval "class #{class_name} < #{self}; end"

      t = parent.const_get(class_name)

      t.class_eval do 
        many_to_one :parent, class: parent, key: :parent_uuid, primary_key: :uuid
        alias_method parent_name, :parent
      end

      t.class_eval &block

      parent.class_eval do
        define_method(name.to_s+"_task") do
          t.find_or_create_for(self)
        end

        def_dataset_method("#{name}_tasks") do
         t.where('parent_uuid in ?', self.select(:uuid))
        end

        define_method(name) do |**opts|
          task = t.start_for(self, **opts)
        end

        def_dataset_method("#{name}") do |**opts|
          all.each do |parent|
            t.start_for(parent, **opts)
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
