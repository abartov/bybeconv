class UserController < ApplicationController
  before_filter :require_admin, only: [:list, :make_editor, :make_admin, :unmake_editor]
  before_filter :require_user

  def set_pref
    unless current_user.id == params[:id].to_i
      render json: { message: 'Forbidden' }, status: 403
    else
      u = User.find(params[:id].to_i)
      if u.nil?
        render json: { message: 'Not found' }, status: 404
      else
        u.preferences.set(params[:pref] => params[:value])
        u.preferences.save!
        Rails.cache.write("u_#{current_user.id}_#{params[:pref]}", params[:value])
        render json: { message: "pref set" }, status: :ok
      end
    end
  end

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
