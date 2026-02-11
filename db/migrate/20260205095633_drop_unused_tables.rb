class DropUnusedTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :email_verifications if table_exists?(:email_verifications)
    drop_table :password_resets if table_exists?(:password_resets)
    drop_table :transaction_notifications if table_exists?(:transaction_notifications)
  end

  def down
    # No easy way to restore dropped tables without definitions,
    # but since they are unused we can leave this empty or raise IrreversibleMigration
    raise ActiveRecord::IrreversibleMigration
  end
end
