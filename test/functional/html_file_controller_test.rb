require 'test_helper'

class HtmlFileControllerTest < ActionController::TestCase
  test 'should get analyze' do
    get :analyze
    assert_response :success
  end

  test 'should get analyze_all' do
    get :analyze_all
    assert_response :success
  end

  test 'should get list' do
    get :list
    assert_response :success
  end
end
