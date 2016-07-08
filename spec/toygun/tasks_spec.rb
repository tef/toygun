require 'spec_helper'

describe Toygun::TaskTransition do
  let(:task) { Toygun::Task.find_or_create(resource_uuid: 'ffffffff-ffff-ffff-ffff-ffffffffffff', name: "stuff", state: "__stop__") }
  let(:time) { Time.now - 1000 }

  describe "a state" do
    let(:state) { Toygun::TaskTransition.create(task_uuid: task.uuid, from: "a", to:"b", step:0) }

    it "has a fresh created_at by default" do
      expect(state.created_at).to be > Time.now - 1
    end

    it "can specify created_at" do
      t = Time.now.round(6) - 10000
      ns = Toygun::TaskTransition.create(task_uuid: task.uuid, from: "a", to:"b", 
        created_at: t, step: 0)
      expect(ns.created_at).to eq(t)
    end
  end
end

describe Toygun::Task do
  before(:all) do
    module Toygun
      class DummyObject < Sequel::Model # make a dummy table for testing
        plugin :schema
        set_schema do
          primary_key :uuid, :uuid, default: Sequel.function('uuid_generate_v4')
        end

        create_table!

        include Subtasks

        def_task "test" do
          field :a
          field :b

          state "beginning" do
            transition "middle"
          end

          state "middle" do
            transition "end"
          end

          state "end" do
            stop
          end
        end

        def_task :another do
          state "a" do
            transition "b"
          end
          state "b" do
            stop
          end
        end
      end
    end
  end

  let (:dummy) { Toygun::DummyObject.create }

  describe 'Test' do
    it 'should exist' do
      expect(Toygun::DummyObject::Test.superclass).to be Toygun::Task
    end
  end

  it 'should not be running when not created' do
    obj = Toygun::DummyObject.create
    expect(obj.test_running?).to be_falsey
    expect(obj.tasks).to eq([])
  end
    
  describe 'instance methods' do
    it 'should have a tasks list' do
      expect(dummy.tasks).to be_an Array
      expect(dummy.tasks_dataset).to be_a Sequel::Dataset
    end

    it 'should have a test_task method' do
      expect(dummy.test_task).to be_a Toygun::DummyObject::Test
    end

    it 'can run active tasks' do
      dummy.test_task.transition "beginning"
      dummy.run_active_tasks
      expect(dummy.test_task.state).to eq("middle")
    end
    it 'can run active tasks but not stopped ones' do
      dummy.test_task.transition "beginning"
      expect(dummy.test_task.state).to eq("beginning")
      dummy.another_task.stop
      dummy.run_active_tasks
      expect(dummy.test_task.state).to eq("middle")
      expect(dummy.another_task.state).to eq("__stop__")
    end
  end


  describe 'tasks should be able to run' do
    it 'should be created stopped' do
      dummy.tasks_dataset.delete
      dummy.test_task
      expect(dummy.test_task.state).to eq("__stop__")
    end

    it 'should be running when started' do
      dummy.test
      expect(dummy.test_task.running?).to be_truthy
    end

    it 'should take args, and reset them on start' do
      dummy.test_task.stop
      dummy.test a: '1'
      expect(dummy.test_task.attrs.to_h).to eq({a: '1'})
      dummy.test_task.stop
      dummy.test b: '1'
      expect(dummy.test_task.attrs.to_h).to eq({b: '1'})
    end
    it 'should take args' do
      dummy.test_task.update(attrs: {})
      dummy.test_task.transition "beginning", b: '1'
      expect(dummy.test_task.attrs).to eq({b: '1'})
    end

    it 'should not be running when stopped' do
      dummy.test_task.stop
      expect(dummy.test_task.running?).to be_falsey
    end

    it 'does not run when panicing' do
      dummy.test_task.panic
      expect { dummy.test_task.tick }.to raise_error(Toygun::State::Panic)
    end

    it 'complains about invalid states' do
      t = dummy.test_task
      expect { t.transition "missing" }.to raise_error(Toygun::State::Missing)
    end

    it 'complains about invalid states' do
      t = dummy.test_task
      t.state = "missing"
      expect { t.tick }.to raise_error(Toygun::State::Missing)
    end

    it 'should tick' do
      dummy.test
      expect(dummy.test_task.state).to eq("beginning")
      dummy.test_task.tick
      expect(dummy.test_task.state).to eq("middle")
      dummy.test_task.tick
      expect(dummy.test_task.state).to eq("end")
      dummy.test_task.tick
      expect(dummy.test_task.state).to eq("__stop__")
    end

    it 'should rewind' do
      dummy.test_task.transition "beginning"
      dummy.test_task.transition "middle"
      expect(dummy.test_task.state).to eq("middle")
      dummy.test_task.rewind 1
      expect(dummy.test_task.state).to eq("beginning")
      dummy.test_task.stop
    end

    it 'should rewind 2' do
      dummy.test_task.transition "beginning"
      dummy.test_task.transition "middle"
      dummy.test_task.transition "end"
      expect(dummy.test_task.state).to eq("end")
      dummy.test_task.rewind 2
      expect(dummy.test_task.state).to eq("beginning")
      dummy.test_task.stop
    end
  end


  it "should have a resource" do
    expect(dummy.test_task.dummy_object.uuid).to eq(dummy.uuid)
    expect(dummy.test_task.dummy_object).to eq(dummy)
  end


  it "prevents multiple concurrent transitions" do
    task = dummy.test_task
    task.transition "beginning"
    task.state = "other"
    # sneak in a state transition without the model noticing
    expect(task.state).to eq("other")
    expect { task.transition "__stop__" }.to raise_error(Toygun::State::Desynchronized)
  end

end
