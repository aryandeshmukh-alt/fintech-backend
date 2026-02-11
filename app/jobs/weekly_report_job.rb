class WeeklyReportJob < ApplicationJob
  queue_as :default

  def perform(delivery_method = :deliver_later)
    User.includes(:user_transaction_stat).find_each do |user|
      start_date = 7.days.ago.beginning_of_day
      end_date = Time.current

      transactions = user.transactions.where(created_at: start_date..end_date)
      next if transactions.empty? # Don't send empty reports

      stats = user.user_transaction_stat
      TransactionMailer.weekly_report(user, transactions.to_a, stats).send(delivery_method)
    end
  end
end
