require 'test_helper'

class HtmlDirsControllerTest < ActionController::TestCase
  setup do
    @html_dir = html_dirs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:html_dirs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create html_dir" do
    assert_difference('HtmlDir.count') do
      post :create, html_dir: @html_dir.attributes
    end

    assert_redirected_to html_dir_path(assigns(:html_dir))
  end

  test "should show html_dir" do
    get :show, id: @html_dir.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @html_dir.to_param
    assert_response :success
  end

  test "should update html_dir" do
    put :update, id: @html_dir.to_param, html_dir: @html_dir.attributes
    assert_redirected_to html_dir_path(assigns(:html_dir))
  end

  test "should destroy html_dir" do
    assert_difference('HtmlDir.count', -1) do
      delete :destroy, id: @html_dir.to_param
    end

    assert_redirected_to html_dirs_path
  end
end
