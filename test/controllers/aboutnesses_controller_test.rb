require 'test_helper'

class AboutnessesControllerTest < ActionController::TestCase
  test "should get remove" do
    get :remove
    assert_response :success
  end

end
