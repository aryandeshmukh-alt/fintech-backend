require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @notification = Notification.create!(user: @user, title: "T", message: "M")
    post api_v1_auth_login_url, params: { email: @user.email, password: 'password123' }
  end

  test "should get notifications" do
    get api_v1_notifications_url
    assert_response :success
  end

  test "should mark as read" do
    patch mark_read_api_v1_notification_url(@notification)
    assert_response :success
    assert @notification.reload.read
  end

  test "should mark all as read" do
    post mark_all_read_api_v1_notifications_url
    assert_response :success
  end

  test "should destroy notification" do
    assert_difference("Notification.count", -1) do
      delete api_v1_notification_url(@notification)
    end
    assert_response :success
  end
end
