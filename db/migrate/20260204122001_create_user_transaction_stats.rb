class CreateUserTransactionStats < ActiveRecord::Migration[8.1]
  def change
    create_table :user_transaction_stats, force: :cascade do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :total_txns, default: 0, null: false
      t.decimal :total_amount, precision: 18, scale: 2, default: 0.0, null: false
      t.decimal :avg_amount, precision: 15, scale: 2, default: 0.0, null: false
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
