class Transaction < ApplicationRecord
  belongs_to :user
  has_one :fraud_evaluation, dependent: :destroy, foreign_key: 'transaction_id'

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :status, presence: true

  enum :status, { pending: 'PENDING', success: 'SUCCESS', flagged: 'FLAGGED', blocked: 'BLOCKED' }, default: :pending
  enum :payment_method, { card: 'card', upi: 'upi', bank_transfer: 'bank_transfer', wallet: 'wallet' }, default: :card
end
