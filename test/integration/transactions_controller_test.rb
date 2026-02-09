require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # Login manually by setting session
    post api_v1_auth_login_url, params: { email: @user.email, password: 'password123' }
  end

  test "should get index" do
    get api_v1_transactions_url
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert_not_nil json_response["data"]["transactions"]
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      post api_v1_transactions_url, params: { 
        transaction: { 
          amount: 500, 
          payment_method: "upi", 
          device_id: "test_device" 
        } 
      }
    end
    assert_response :created
  end

  test "should fail without device_id" do
    post api_v1_transactions_url, params: { 
      transaction: { 
        amount: 500, 
        payment_method: "card" 
      } 
    }
    assert_response :unprocessable_entity
  end
end
