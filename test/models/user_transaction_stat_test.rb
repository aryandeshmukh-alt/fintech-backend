require "test_helper"

class UserTransactionStatTest < ActiveSupport::TestCase
  def setup
    @stat = user_transaction_stats(:one)
  end

  test "valid stat" do
    assert @stat.valid?
  end

  test "invalid without user" do
    @stat.user = nil
    assert_not @stat.valid?
  end
end
