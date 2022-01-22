class SessionController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def login
  end

  def do_login
    case params[:commit]
    when 'Google'
      redirect_to '/auth/google_oauth2'
    when 'Twitter'
      redirect_to '/auth/twitter'
    else
      redirect_to '/', flash: { error: 'No such login method' }
    end
  end

  def create
    User.transaction do
      @user = User.from_omniauth(auth_hash)

      # if user doesn't have BaseUser (i.e. if this is a new sign up) we link BaseUser from session to newly created user
      if @user.base_user.nil? && base_user.user.nil?
        base_user.session_id = nil
        base_user.user = @user
        base_user.save!
      end

    end
    reset_session
    session[:user_id] = @user.id
    redirect_to '/'
  end

  def destroy
    reset_session
    session[:user_id] = nil
    redirect_to '/'
  end

  def dismiss_sitenotice
    session[:dismissed_sitenotice] = true
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
