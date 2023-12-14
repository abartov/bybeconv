# handle everything related to Tags and Taggings
class TaggingsController < ApplicationController
  before_action :require_user # for now, we don't allow anonymous taggings
  before_action :require_editor, only: [:rename_tag]
  layout false, only: [:render_tags, :suggest, :add_tagging_popup, :listall_tags]

  def add_tagging_popup
    @taggable = instantiate_taggable(params[:taggable_type], params[:taggable_id])
    if @taggable.class == Manifestation
      @author = @taggable.authors.first
    elsif @taggable.class == Person
      @author = @taggable
    end
    @tagging = Tagging.new
    @tagging.suggester = current_user
    @tagging.status = :pending
    @tagging.taggable = @taggable
    @recent_tags_by_user = current_user.recent_tags_used
  end
  def create
    if params[:tag].present?
      if params[:tag_id].present? # selecting from autocomplete would populate this
        tag = Tag.find(params[:tag_id])
      else # user may have typed an existing tag name or alias without selecting from autocomplete
        tname = TagName.find_by_name(params[:tag])
        tag = tname.nil? ? nil : tname.tag
      end
      if tag.nil? # user submitted a nonexistent tag name
        tag = Tag.create!(name: params[:tag], creator: current_user, status: :pending)
      end
    else
      if params[:suggested_tag_id].present?
        tag = Tag.find(params[:suggested_tag_id])
      else
        head :not_found
      end
    end
    if tag
      @t = Tagging.new(taggable: instantiate_taggable(params[:taggable_type], params[:taggable_id]), suggester: current_user, status: :pending)
      tag.taggings << @t
    end
  end

  def destroy
    # TODO: implement
    tagging = Tagging.find(params[:id])
    unless tagging.nil?
      if tagging.pending? && (tagging.suggested_by == current_user.id || (current_user.editor? && current_user.has_bit?('moderate_tags')))
        @taggable_id = tagging.taggable_id
        @taggable_type = tagging.taggable_type
        tagging.destroy
      end
    end
  end

  def list_tags # for backend
    # TODO: handle filters
    @page = params[:page]
    @page = 1 unless @page.present?
    @tags = Tag.approved.all.page(@page)
    render 'list_tags', layout: true
  end

  def listall_tags # for frontend
    @tags = Tagging.approved.joins(:tag).order(:name).pluck(:tag_id,:name).group_by(&:pop).map{|x| {id: x[1][0], name: x[0], count: x[1].length}} # TODO: at some point, we'll need to paginate this
    #@tags = Tag.approved.all.order(:name) 
  end

  def render_tags
    @taggable = instantiate_taggable(params[:taggable_type], params[:taggable_id])
    @taggings = @taggable.nil? ? [] : @taggable.taggings
  end

  def suggest
    @tag_suggestions = {}
    if params[:author].present?
      @tag_suggestions[:used_on_other_works] = Person.find(params[:author]).cached_popular_tags_used_on_works
    end
    if current_user.present?
      @tag_suggestions[:popular_tags_by_user] = current_user.cached_popular_tags_used
      @tag_suggestions[:recent_tags_by_user] = current_user.recent_tags_used
    end
    @tag_suggestions[:popular_tags] = Tag.cached_popular_tags
  end

  # editor actions
  def rename_tag
    @tag = Tag.find(params[:id])
    newname = params[:name]
    existingtag = Tag.by_name(newname)
    if existingtag.empty?
      @tag.name = newname
      @tag.save!
      flash[:notice] = t(:tag_renamed, newname: newname)
    else
      @tag.merge_taggings_into(existingtag.first)
      @tag.destroy
      flash[:notice] = t(:taggings_merged, toname: existingtag.first.name)
    end
    # TODO: render or redirect
  end

  protected
  def instantiate_taggable(klass, id)
    case klass
    when 'Manifestation'
      Manifestation.find(id)
    when 'Person'
      Person.find(id)
    when 'Anthology'
      Anthology.find(id)
    when 'Work'
      Work.find(id)
    when 'Expression'
      Expression.find(id)
    end
  end
end
