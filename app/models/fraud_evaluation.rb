class FraudEvaluation < ApplicationRecord
  belongs_to :financial_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'

  validates :risk_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
