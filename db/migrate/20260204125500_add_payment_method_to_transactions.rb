class AddPaymentMethodToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :payment_method, :string, default: 'card'
    add_index :transactions, :payment_method
  end
end
