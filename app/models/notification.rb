class Notification < ApplicationRecord
  belongs_to :user

  # Validations
  validates :notification_type, presence: true, inclusion: { in: %w[transaction security system info] }
  validates :title, presence: true, length: { maximum: 255 }
  validates :message, presence: true, length: { maximum: 1000 }
  validates :priority, presence: true, inclusion: { in: %w[low medium high] }

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END")) }

  # Class methods
  def self.create_transaction_notification(user:, transaction:, status:)
    amount = transaction.amount.to_f
    risk_score = transaction.risk_score || 0
    formatted_amount = ActiveSupport::NumberHelper.number_to_delimited(amount.to_i)

    case status.to_s.upcase
    when 'BLOCKED'
      create!(
        user: user,
        notification_type: 'security',
        title: 'Transaction Blocked',
        message: "A transaction of ₹#{formatted_amount} was blocked due to high risk (Score: #{risk_score}).",
        priority: 'high',
        data: {
          transaction_id: transaction.id,
          amount: amount,
          risk_score: risk_score,
          status: status
        }
      )
    when 'FLAGGED'
      create!(
        user: user,
        notification_type: 'transaction',
        title: 'Transaction Flagged',
        message: "A transaction of ₹#{formatted_amount} was flagged for review (Score: #{risk_score}).",
        priority: 'medium',
        data: {
          transaction_id: transaction.id,
          amount: amount,
          risk_score: risk_score,
          status: status
        }
      )
    end
  end
end