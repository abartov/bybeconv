# handle everything related to Tags and Taggings
class TaggingsController < ApplicationController
  before_action :require_user # for now, we don't allow anonymous taggings
  before_action :require_editor, only: [:rename_tag]
  layout false

  def create
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
    @t = Tagging.new(taggable: instantiate_taggable(params[:taggable_type], params[:taggable_id]), suggester: current_user, status: :pending)
    tag.taggings << @t
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
  
  def render_tags
    @manifestation = Manifestation.find(params[:manifestation_id])
    @taggings = @manifestation.nil? ? [] : @manifestation.taggings
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
      flash[:notice] = t(:taggings_merged, toname: existingtag.first.name))
    end
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
