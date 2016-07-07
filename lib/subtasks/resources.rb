module Toygun
  class ResourceTransition < Sequel::Model
    plugin :timestamps, update_on_create: true

    def_dataset_method :latest do
      order(:step.desc).first
    end

    def duration
      Time.now - created_at
    end
  end

  class Resource < Sequel::Model
    # todo, define lifecycle here, i.e
    # creating states
    # operational states
    # deleting states
    # archiving states

    plugin :single_table_inheritance, :name
    plugin :timestamps, update_on_create: true

    one_to_many :transitions, key: :resource_uuid, primary_key: :uuid, order: Sequel.desc(:step), class: ResourceTransition
    one_to_many :tasks, class: 'Toygun::Task', key: :parent_uuid, primary_key: :uuid

    include State::InstanceMethods
    extend State::ClassMethods

    def_dataset_method :active do
      exclude(state: State::STOP)
    end

    def self.def_task(name, &block)
      Task.define_task_on(self, name, &block)
    end

    def self.task_states
      {
        "starting" => Proc.new {},
        "running" => Proc.new {},
        "stopping" => Proc.new {},
        "restarting" => Proc.new {},
      }
    end

    def self.state
      raise "no"
    end

    def tick
      # err handling
      super
      tasks_dataset.active.each do |t|
        t.tick
      end
    end
  end
end
