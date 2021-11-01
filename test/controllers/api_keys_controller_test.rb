require 'test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  setup do
    @enabled_key = create(:api_key)
    @disabled_key = create(:api_key, status: :disabled, description: 'Disabled Key')
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "create succeed" do
    assert_difference -> { ApiKey.count } => 1, -> {ActionMailer::Base.deliveries.size} => 2 do
      post :create, params: { api_key: { description: 'test', email: 'New@test.com' } }
    end
    assert_redirected_to '/'
    assert_equal 'Api key was successfully created, check email for details', flash.notice

    key = ApiKey.order(id: :desc).first
    assert_equal 'new@test.com', key.email
    assert_equal 'test', key.description
    assert key.status_enabled?
    assert_not_empty key.key

    email = ActionMailer::Base.deliveries[-1]
    assert_equal I18n.t('api_keys_mailer.key_created.subject'), email.subject
    assert_equal [key.email], email.to
    assert email.body.include?(key.key)

    email = ActionMailer::Base.deliveries[-2]
    assert_equal I18n.t('api_keys_mailer.key_created_to_editor.subject'), email.subject
    assert_equal [ApiKeysMailer::EDITOR_EMAIL], email.to
    assert email.body.include?(key.description)
  end

  test "create failed" do
    assert_no_difference 'ApiKey.count' do
      # trying to create key with already taken email
      post :create, params: { api_key: { description: 'test', email: @enabled_key.email } }
    end
    assert_response :unprocessable_entity
  end

  test "index" do
    set_admin
    get :index
    assert_response :success
    assert_select 'h1', 'Listing api_keys'
  end

  test "edit" do
    set_admin
    get :edit, params: { id: @disabled_key.id }
    assert_response :success
  end

  test "update succeed" do
    set_admin
    put :update, params: { id: @disabled_key.id, api_key: { status: :enabled, description: 'New Value' } }
    assert_redirected_to api_keys_path
    assert_equal 'Api key was successfully updated.', flash.notice

    # Ensuring key was updated
    @disabled_key.reload
    assert @disabled_key.status_enabled?
    assert_equal 'New Value', @disabled_key.description
  end

  test "update failed" do
    set_admin
    put :update, params: { id: @disabled_key.id, api_key: { status: '', description: 'New Value' } }
    assert_response :unprocessable_entity

    # Ensuring key was not updated
    @disabled_key.reload
    assert @disabled_key.status_disabled?
    assert_equal 'Disabled Key', @disabled_key.description
  end

  test "destroy succeed" do
    set_admin
    assert_difference 'ApiKey.count', -1 do
      delete :destroy, params: { id: @disabled_key.id }
    end
    assert_redirected_to api_keys_url
  end

  private

  def set_admin
    u = users(:a_admin)
    session[:user_id] = u.id
  end
end
