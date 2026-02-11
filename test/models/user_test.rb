require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "valid user" do
    assert @user.valid?
  end

  test "invalid without email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "invalid without first_name" do
    @user.first_name = nil
    assert_not @user.valid?
  end

  test "invalid without last_name" do
    @user.last_name = nil
    assert_not @user.valid?
  end

  test "email must be unique" do
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
  end

  test "default role is customer" do
    new_user = User.new(email: "new@example.com", password: "password123", first_name: "A", last_name: "B")
    assert new_user.customer?
  end

  test "default status is active" do
    new_user = User.new(email: "new2@example.com", password: "password123", first_name: "A", last_name: "B")
    assert new_user.active?
  end
end
