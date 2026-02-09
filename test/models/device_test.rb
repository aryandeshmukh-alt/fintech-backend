require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  def setup
    @device = devices(:one)
  end

  test "valid device" do
    assert @device.valid?
  end

  test "invalid without device_id" do
    @device.device_id = nil
    assert_not @device.valid?
  end

  test "invalid without user" do
    @device.user = nil
    assert_not @device.valid?
  end
end
