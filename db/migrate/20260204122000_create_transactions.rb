class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions, id: :uuid, force: :cascade do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :device_id
      t.string :status, null: false, default: 'PENDING'
      t.integer :risk_score, default: 0
      t.string :ip_address

      t.timestamps
    end

    add_index :transactions, :status
    add_index :transactions, :created_at
  end
end
