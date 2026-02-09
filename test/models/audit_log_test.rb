require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "should create audit log" do
    assert_difference("AuditLog.count") do
      AuditLog.create!(
        event_type: "LOGIN",
        entity_type: "User",
        entity_id: "1",
        description: "User logged in"
      )
    end
  end
end
