class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_paper_trail_whodunnit
  after_filter :set_access_control_headers

  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*' 
    headers['Access-Control-Request-Method'] = '*' 
  end

  private
  def require_editor
    return true if current_user && current_user.editor?
    redirect_to '/', flash: {error: 'Not an editor'}
  end
  def require_admin
    return true if current_user && current_user.admin?
    redirect_to '/', flash: {error: 'Not an admin'}
  end
  def require_user
    return true if current_user
    redirect_to session_login_path, flash: {error: 'You must be logged in to access this page'}
  end
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  def html_entities_coder
    @html_entities_coder ||= HTMLEntities.new
  end
  helper_method :current_user, :html_entities_coder
end
