Sequel.migration do
  up do
    create_table :tasks do 
      uuid :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid :parent_uuid

      String :name, null: false
      String :state

      jsonb :attrs

      timestamptz :created_at
      timestamptz :updated_at

      index :parent_uuid

      index [:created_at]
      index [:updated_at]
      index [:name, :updated_at, :state]

      index [:parent_uuid, :name, :state]

      index [:parent_uuid, :name], where: "state <> '__stop__'", unique:true
      index [:parent_uuid, :name], name: "parent_uuid_name_all_index"
    end

    create_table :task_transitions do
      uuid :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true

      foreign_key :task_uuid, :tasks, null: false, type: "uuid"

      smallint :step

      String :from
      String :to

      timestamptz :created_at

      index :task_uuid
      index :created_at
      index [:task_uuid, :step], unique: true
    end
  end

  down do
    drop_table :task_transitions
    drop_table :tasks
  end
end
