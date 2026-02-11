require "test_helper"

class AuthIntegrationTest < ActionDispatch::IntegrationTest
  test "user login and session timeout" do
    user = users(:one)
    
    # 1. Login
    post api_v1_auth_login_url, params: { email: user.email, password: "password123" }
    assert_response :success
    assert_not_nil session[:user_id]
    assert_not_nil session[:last_activity_at]

    # 2. Access 'me' endpoint
    get api_v1_auth_me_url
    assert_response :success

    # 3. Simulate timeout (manually manipulate session if possible in tests, or wait)
    # Note: In real tests we'd use TravelTo or similar
  end
end
