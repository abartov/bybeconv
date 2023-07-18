class TaggingsController < ApplicationController
  before_action :require_user # for now, we don't allow anonymous taggings
  layout false

  def create
    if params[:new_tagging_tag_id].present? # selecting from autocomplete would populate this
      tag = Tag.find(params[:new_tagging_tag_id])
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
      if tagging.status == :pending && tagging.suggested_by == current_user.id
        @manifestation_id = tagging.manifestation_id
        tagging.destroy
      end
    end
  end

  def render_tags
    @manifestation = Manifestation.find(params[:manifestation_id])
    @taggings = @manifestation.nil? ? [] : @manifestation.taggings
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
