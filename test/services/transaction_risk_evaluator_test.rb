require "test_helper"

class TransactionRiskEvaluatorTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @stat = user_transaction_stats(:one)
    @device = devices(:one)
  end

  test "should evaluate low risk transaction as success" do
    transaction = Transaction.create!(
      amount: 100,
      payment_method: "card",
      device_id: @device.device_id,
      user: @user
    )
    
    evaluator = TransactionRiskEvaluator.new(transaction)
    status = evaluator.evaluate
    
    assert_equal :success, status
    assert_equal "success", transaction.reload.status
    assert_equal 0, transaction.risk_score
  end

  test "should flag high amount deviation" do
    # stats.avg_amount is 100. Let's send 1001 (10x deviation)
    transaction = Transaction.create!(
      amount: 1001,
      payment_method: "card",
      device_id: @device.device_id,
      user: @user
    )
    
    evaluator = TransactionRiskEvaluator.new(transaction)
    status = evaluator.evaluate
    
    assert_equal :flagged, status
    assert transaction.risk_score >= 40
  end

  test "should block high risk score" do
    # Trigger multiple rules
    # 1. Untrusted device (30)
    # 2. High amount deviation (40)
    transaction = Transaction.create!(
      amount: 1001,
      payment_method: "card",
      device_id: "untrusted_device",
      user: @user
    )
    
    evaluator = TransactionRiskEvaluator.new(transaction)
    status = evaluator.evaluate
    
    assert_equal :blocked, status
    assert transaction.reload.blocked?
  end
end
