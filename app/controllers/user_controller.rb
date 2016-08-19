class UserController < ApplicationController
  before_filter :require_admin

  def list
    @user_list = User.page params[:page]
  end

  def make_editor
    u = User.find(params[:id])
    u.editor = true
    u.save!
    redirect_to '/', flash: { notice: "#{u.name} is now an editor." }
  end

  def make_admin
    u = User.find(params[:id])
    u.admin = true
    u.save!
    redirect_to '/', flash: {notice: "#{u.name} is now an admin."}
  end

  def unmake_editor
    u = User.find(params[:id])
    u.editor = false
    u.save!
    redirect_to '/', flash: {notice: "#{u.name} is no longer an editor."}
  end

end
