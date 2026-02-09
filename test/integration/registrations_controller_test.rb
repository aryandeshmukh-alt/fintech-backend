require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should register new user" do
    assert_difference("User.count") do
      post api_v1_auth_register_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "New",
          last_name: "User"
        }
      }
    end
    assert_response :created
  end

  test "should fail with invalid data" do
    post api_v1_auth_register_url, params: {
      user: {
        email: "invalid",
        password: "123"
      }
    }
    assert_response :unprocessable_entity
  end
end
