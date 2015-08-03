require 'test_helper'

class ProofControllerTest < ActionController::TestCase
  test 'should get submit' do
    get :submit
    assert_response :success
  end

  test 'should get list' do
    get :list
    assert_response :success
  end

  test 'should get show' do
    get :show
    assert_response :success
  end

  test 'should get resolve' do
    get :resolve
    assert_response :success
  end
end
