# frozen_string_literal: true

# Controller to work with InvolvedAuthority records
class InvolvedAuthoritiesController < ApplicationController
  before_action :require_editor
  before_action :set_involved_authority, only: :destroy

  # DELETE /involved_authorities/1 or /involved_authorities/1.json
  def destroy
    manifestations = if @involved_authority.item.is_a? Expression
                       @involved_authority.item.manifestations
                     elsif @involved_authority.item.is_a? Work
                       @involved_authority.item.expressions.map(&:manifestations).flatten
                     end

    manifestations.compact.each(&:recalc_cached_people!) if manifestations.present?

    @the_id = "ia#{@involved_authority.id}"
    @involved_authority.destroy!
  end

  private

  def set_involved_authority
    @involved_authority = InvolvedAuthority.find(params[:id])
  end
end
