require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post api_v1_auth_login_url, params: { email: @user.email, password: 'password123' }
  end

  test "should get analytics" do
    get api_v1_analytics_url, params: { period: '7d' }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert_not_nil json_response["data"]["stats"]
  end
end
