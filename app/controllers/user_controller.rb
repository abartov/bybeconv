class UserController < ApplicationController
  before_filter :require_admin

  def list
    @user_list = User.page params[:page]
  end

  def make_editor
    u = User.find(params[:id])
    u.editor = true
    u.save!
    redirect_to '/', flash: {notice: "#{u.name} is now an editor."}
  end

  def unmake_editor
  end
end
