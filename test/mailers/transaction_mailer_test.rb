require "test_helper"

class TransactionMailerTest < ActionMailer::TestCase
  setup do
    @transaction = transactions(:one)
    @user = users(:one)
  end

  test "blocked_alert" do
    email = TransactionMailer.blocked_alert(@transaction).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [@user.email], email.to
    assert_equal "URGENT: Transaction Blocked - Security Alert", email.subject
    assert_match "blocked", email.body.encoded
  end

  test "weekly_report" do
    stats = user_transaction_stats(:one)
    transactions = [@transaction]
    email = TransactionMailer.weekly_report(@user, transactions, stats).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [@user.email], email.to
    assert_equal "Your Weekly Spending & Security Report", email.subject
  end
end
