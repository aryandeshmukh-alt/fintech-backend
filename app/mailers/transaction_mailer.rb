class TransactionMailer < ApplicationMailer
  default from: "notifications@fintech-risk-engine.com"

  def blocked_alert(transaction)
    @transaction = transaction
    @user = transaction.user

    mail(
      to: @user.email,
      subject: "URGENT: Transaction Blocked - Security Alert"
    )
  end

  def weekly_report(user, transactions, stats)
    @user = user
    @transactions = transactions
    @stats = stats
    @start_date = 7.days.ago.beginning_of_day
    @end_date = Time.current

    mail(
      to: @user.email,
      subject: "Your Weekly Spending & Security Report"
    )
  end
end
