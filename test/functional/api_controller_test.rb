require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get query" do
    get :query
    assert_response :success
  end

end
