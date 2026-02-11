class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid, force: :cascade do |t|
      t.string :event_type, null: false
      t.string :entity_type, null: false
      t.string :entity_id, null: false
      t.text :description

      t.timestamps
    end

    add_index :audit_logs, [ :entity_type, :entity_id ]
    add_index :audit_logs, :event_type
  end
end
