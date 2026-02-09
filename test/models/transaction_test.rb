require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with all attributes" do
    transaction = Transaction.new(
      amount: 100,
      payment_method: "card",
      device_id: "device_123",
      status: "pending",
      user: @user
    )
    assert transaction.valid?
  end

  test "should require device_id" do
    transaction = Transaction.new(
      amount: 100,
      payment_method: "card",
      user: @user
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:device_id], "can't be blank"
  end

  test "amount must be greater than 0" do
    transaction = Transaction.new(amount: 0, user: @user)
    assert_not transaction.valid?
  end
end
