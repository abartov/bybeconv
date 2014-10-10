require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get make_editor" do
    get :make_editor
    assert_response :success
  end

  test "should get unmake_editor" do
    get :unmake_editor
    assert_response :success
  end

end
