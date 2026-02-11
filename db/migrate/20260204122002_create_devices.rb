class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices, force: :cascade do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_id, null: false
      t.datetime :first_seen_at, null: false

      t.timestamps
    end

    add_index :devices, [ :user_id, :device_id ], unique: true
  end
end
