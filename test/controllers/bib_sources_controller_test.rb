require 'test_helper'

class BibSourcesControllerTest < ActionController::TestCase
  setup do
    @bib_source = bib_sources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bib_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bib_source" do
    assert_difference('BibSource.count') do
      post :create, bib_source: { api_key: @bib_source.api_key, comments: @bib_source.comments, port: @bib_source.port, source_type: @bib_source.source_type, title: @bib_source.title, url: @bib_source.url }
    end

    assert_redirected_to bib_source_path(assigns(:bib_source))
  end

  test "should show bib_source" do
    get :show, id: @bib_source
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bib_source
    assert_response :success
  end

  test "should update bib_source" do
    patch :update, id: @bib_source, bib_source: { api_key: @bib_source.api_key, comments: @bib_source.comments, port: @bib_source.port, source_type: @bib_source.source_type, title: @bib_source.title, url: @bib_source.url }
    assert_redirected_to bib_source_path(assigns(:bib_source))
  end

  test "should destroy bib_source" do
    assert_difference('BibSource.count', -1) do
      delete :destroy, id: @bib_source
    end

    assert_redirected_to bib_sources_path
  end
end
