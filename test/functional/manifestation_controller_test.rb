require 'test_helper'

class ManifestationControllerTest < ActionController::TestCase
  test 'should get show' do
    get :show
    assert_response :success
  end

  test 'should get render' do
    get :render
    assert_response :success
  end

  test 'should get edit' do
    get :edit
    assert_response :success
  end
end
