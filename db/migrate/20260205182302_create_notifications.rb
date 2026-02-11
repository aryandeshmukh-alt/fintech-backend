class CreateNotifications <ActiveRecord::Migration[8.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type, null: false, default: 'transaction'
      t.string :title, null: false
      t.text :message, null: false
      t.string :priority, null: false, default: 'low'
      t.boolean :read, null: false, default: false
      t.jsonb :data, default: {}

      t.timestamps
    end

    add_index :notifications, [ :user_id, :read ]
    add_index :notifications, [ :user_id, :created_at ]
  end
end
