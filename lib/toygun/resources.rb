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
    one_to_many :tasks, class: 'Toygun::Task', key: :resource_uuid, primary_key: :uuid
    one_to_many :children, class: 'Toygun::Resource', key: :parent_uuid, primary_key: :uuid
    one_to_one :parent, class: 'Toygun::Resource', key: :uuid, primary_key: :parent_uuid

    include State::InstanceMethods
    plugin ModelAttributes

    def_dataset_method :active do
      exclude(state: State::STOP)
    end

    def self.def_task(name, &block)
      Task.define_task_on(self, name, &block)
    end

    def self.has_state?(new_state)
      State.builtin_states.include?(new_state) || self.resource_states.include?(new_state)
    end

    def self.resource_states
      [ "starting", "running", "stopping", "restarting",]
    end

    def tick
      return if state == State::STOP
      transition "starting" if state == State::NEW

      tasks_dataset.active.each do |t|
        t.tick
      end
    end
  end
end
