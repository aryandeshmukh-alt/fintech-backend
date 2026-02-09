require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get check" do
    get api_v1_health_url
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "ok", json_response["status"]
  end
end
