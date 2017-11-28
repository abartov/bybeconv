class TaggingsController < ApplicationController
  before_filter :require_user # for now, we don't allow anonymous taggings
  layout false

  def create
    tag = Tag.find_by_name(params[:tag])
    if tag.nil?
      tag = Tag.new
      tag.name = params[:tag]
      tag.created_by = params[:suggested_by]
      tag.status = :pending
      tag.save!
    end
    @t = Tagging.new
    @t.manifestation_id = params[:manifestation_id]
    @t.suggested_by = params[:suggested_by]
    @t.status = :pending
    @t.tag = tag
    @t.save!
  end

  def destroy
    # TODO: implement
    tagging = Tagging.find(params[:id])
    unless tagging.nil?
      @manifestation_id = tagging.manifestation_id
      tagging.destroy
    end
  end

  def render_tags
    @manifestation = Manifestation.find(params[:manifestation_id])
    @taggings = @manifestation.nil? ? [] : @manifestation.taggings
  end
end
