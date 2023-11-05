# handle everything related to Tags and Taggings
class TaggingsController < ApplicationController
  before_action :require_user # for now, we don't allow anonymous taggings
  before_action :require_editor, only: [:rename_tag]
  layout false, only: [:render_tags, :suggest]

  def create
    if params[:tag].present?
      if params[:tagname_id].present? # selecting from autocomplete would populate this
        tname = TagName.find(params[:tagname_id])
        tag = tname.tag unless tname.nil?
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
      if tagging.status == :pending && (tagging.suggested_by == current_user.id || (current_user.editor? && current_user.has_bit?('moderate_tags')))
        @manifestation_id = tagging.manifestation_id
        tagging.destroy
      end
    end
  end

  def list_tags
    # TODO: handle filters
    @page = params[:page]
    @page = 1 unless @page.present?
    @tags = Tag.approved.all.page(@page)
    render 'list_tags', layout: true
  end

  def render_tags
    @manifestation = Manifestation.find(params[:manifestation_id])
    @taggings = @manifestation.nil? ? [] : @manifestation.taggings
  end

  def suggest
    @tag_suggestions = {}
    if params[:author].present?
      @tag_suggestions[:used_on_other_works] = Person.find(params[:author]).popular_tags_used_on_works
    end
    if params[:user].present?
      u = User.find(params[:user])
      @tag_suggestions[:popular_tags_by_user] = u.popular_tags_used
      @tag_suggestions[:recent_tags_by_user] = u.recent_tags_used
    end
    @tag_suggestions[:popular_tags] = Tag.by_popularity.limit(10)
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
