class SessionController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
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
    @user = User.from_omniauth(auth_hash)
    reset_session
    session[:user_id] = @user.id
    redirect_to '/'
  end

  def destroy
    reset_session
    session[:user_id] = nil
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
