require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "local preview keeps the requested six character minimum" do
    user = User.new(email: "preview@example.test", password: "local6")
    assert_equal 6, user.minimum_password_length
    assert user.valid?
    assert user.valid_password?("local6")
  end

  test "production rejects short passwords including existing demo hashes" do
    user = User.new(email: "preview@example.test", password: "local6")
    assert user.valid_password?("local6")
    previous = Rails.env
    Rails.env = "production"
    assert_equal 12, user.minimum_password_length
    assert_not user.valid?
    assert user.errors[:password].any?
    assert_not user.valid_password?("local6")
    user.password = "ExclusivePassword123!"
    assert user.valid?, user.errors.full_messages.join(", ")
    assert user.valid_password?("ExclusivePassword123!")
  ensure
    Rails.env = previous if previous
  end
end
