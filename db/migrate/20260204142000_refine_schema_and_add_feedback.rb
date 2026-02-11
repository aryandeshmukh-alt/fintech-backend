class RefineSchemaAndAddFeedback < ActiveRecord::Migration[8.1]
  def change
    # 1. Cleanup: Remove redundant table
    drop_table :user_behaviors if table_exists?(:user_behaviors)

    # 2. Enhancement: Add feedback columns for Option A
    add_column :fraud_evaluations, :is_accurate, :boolean
    add_column :fraud_evaluations, :user_feedback, :text

    # 3. Add index for feedback analysis
    add_index :fraud_evaluations, :is_accurate
  end
end
