require 'test_helper'

class AnthologyTextsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get anthology_texts_create_url
    assert_response :success
  end

  test "should get update" do
    get anthology_texts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get anthology_texts_destroy_url
    assert_response :success
  end

  test "should get show" do
    get anthology_texts_show_url
    assert_response :success
  end

end
