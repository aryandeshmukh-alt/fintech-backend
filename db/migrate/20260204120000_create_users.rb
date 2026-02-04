class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, force: :cascade do |t|
      t.string :email,           null: false
      t.string :password_digest, null: false
      t.string :first_name,      null: false
      t.string :last_name,       null: false
      t.integer :role,           null: false, default: 0 # 0: customer, 1: admin, etc.
      t.integer :status,         null: false, default: 0 # 0: active, 1: suspended, etc.

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
