class CreateFraudEvaluations < ActiveRecord::Migration[8.1]
  def change
    create_table :fraud_evaluations, id: :uuid, force: :cascade do |t|
      t.references :transaction, null: false, foreign_key: true, type: :uuid
      t.integer :risk_score, null: false
      t.text :rules_triggered # Storing as comma-separated or JSON string

      t.timestamps
    end
  end
end
