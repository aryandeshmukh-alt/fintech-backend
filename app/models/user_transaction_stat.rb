class UserTransactionStat < ApplicationRecord
  belongs_to :user

  validates :total_txns, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :avg_amount, numericality: { greater_than_or_equal_to: 0 }
end
