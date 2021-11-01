require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  test "it normalizes email" do
    key = ApiKey.new(email: '  Test@test.com    ')
    key.valid?
    assert_equal 'test@test.com', key.email
  end
end
