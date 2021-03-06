class UserController < ApplicationController
  before_action :require_admin, only: [:list, :make_editor, :make_admin, :unmake_editor, :set_editor_bit]
  before_action :require_user

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
    unless params[:q].nil? || params[:q].empty?
      @user_list = User.where("name like '%#{sanitize(params[:q])}%' OR email like '%#{sanitize(params[:q])}%'").page params[:page]
      @q = params[:q]
    else
      @user_list = User.page params[:page]
    end
  end

  def make_editor
    set_user
    @q = params[:q]
    @u.editor = true
    @u.save!
    redirect_to url_for(action: :list), notice: "#{@u.name} is now an editor."
  end

  def make_admin
    set_user
    @q = params[:q]
    @u.admin = true
    @u.save!
    redirect_to url_for(action: :list), notice: "#{@u.name} is now an admin."
  end

  def unmake_editor
    set_user
    @q = params[:q]
    @u.editor = false
    @u.save!
    redirect_to url_for(action: :list), notice: "#{@u.name} is no longer an editor."
  end

  def show
  end

  def set_editor_bit
    set_user
    @q = params[:q]
    if @u.editor? and params[:bit] and (params[:bit].empty? == false) and params[:set_to] and (params[:set_to].empty? == false)
      if params[:set_to].to_i == 1
        action = t(:added_to_group)
        li = ListItem.where(listkey: params[:bit], item: @u).first
        unless li
          li = ListItem.new(listkey: params[:bit], item: @u)
          li.save!
        end
      else # zero == remove from list having the bit
        action = t(:removed_from_group)
        li = ListItem.where(listkey: params[:bit], item: @u).first
        li.destroy if li
      end
    end
    redirect_to action: :list, notice: "#{@u.name} #{action} #{t(params[:bit])}"
  end

  protected
  def set_user
    @u = User.find(params[:id])
    if @u.nil?
      redirect_to url_for(controller: :admin, action: :index), flash: {error: t(:no_such_user)}
    end
  end
end
