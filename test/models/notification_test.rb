require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @transaction = transactions(:one)
  end

  test "should create transaction notification" do
    assert_difference("Notification.count") do
      Notification.create_transaction_notification(
        user: @user,
        transaction: @transaction,
        status: "FLAGGED"
      )
    end
  end

  test "should be valid" do
    notification = Notification.new(
      user: @user,
      title: "Test",
      message: "Test message",
      notification_type: "transaction"
    )
    assert notification.valid?
  end

  test "unread scope" do
    Notification.create!(user: @user, title: "T", message: "M", read: false)
    Notification.create!(user: @user, title: "T", message: "M", read: true)
    assert_includes Notification.unread, Notification.find_by(read: false)
    assert_not_includes Notification.unread, Notification.find_by(read: true)
  end
end
