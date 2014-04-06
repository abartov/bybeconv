class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_access_control_headers

  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = 'http://benyehuda.org/' 
    headers['Access-Control-Request-Method'] = '*' 
  end

  private
  def require_admin
    return true if current_user && current_user.admin?
    redirect_to '/', flash: {error: 'Not an admin'}
    return false
  end
  def require_user
    return true if current_user
    redirect_to session_login_path, flash: {error: 'You must be logged in to access this page'}
    return false
  end
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
