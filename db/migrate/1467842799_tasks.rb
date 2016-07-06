Sequel.migration do
  up do
    create_table :tasks do 
      uuid :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid :foreign_uuid

      String :name, null: false
      String :state

      jsonb :attrs

      index :foreign_uuid
      index [:foreign_uuid, :name]
      index [:foreign_uuid, :name, :state]
    end

    create_table :task_transitions do
      uuid :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true

      foreign_key :task_uuid, :tasks, null: false, type: "uuid"

      String :from
      String :to

      timestamptz :created_at
      timestamptz :updated_at

      index :task_uuid
      index :created_at
    end
  end

  down do
    drop_table :task_transitions
    drop_table :tasks
  end
end
