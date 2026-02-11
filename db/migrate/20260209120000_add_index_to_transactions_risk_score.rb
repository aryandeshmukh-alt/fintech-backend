class AddIndexToTransactionsRiskScore < ActiveRecord::Migration[8.1]
  def change
    add_index :transactions, :risk_score unless index_exists?(:transactions, :risk_score)
  end
end
