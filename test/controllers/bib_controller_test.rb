require 'test_helper'

class BibControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get pubs_by_person" do
    get :pubs_by_person
    assert_response :success
  end

  test "should get todo_by_location" do
    get :todo_by_location
    assert_response :success
  end

  test "should get mark_pub_as" do
    get :mark_pub_as
    assert_response :success
  end

end
