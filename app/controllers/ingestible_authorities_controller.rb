# frozen_string_literal: true

# Controller to work with ingestible authorities
# Authoritiers for ingestible are stored as JSON array in default_authorities field
class IngestibleAuthoritiesController < ApplicationController
  include LockIngestibleConcern

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible
  before_action :try_to_lock_ingestible

  # responds with js callback
  def create
    highest_seqno = @authorities.pluck('seqno').max || 0
    new_authority = { 'seqno' => highest_seqno + 1, 'role' => params[:role] }
    if params[:new_person].present?
      # Authority not yet present in database
      new_authority['new_person'] = params[:new_person]
    elsif params[:authority_id].present?
      # Existing authority from database
      new_authority['authority_id'] = params[:authority_id].to_i
      new_authority['authority_name'] = params[:authority_name]
    else
      head :bad_request
      return
    end

    @authorities << new_authority
    @ingestible.update!(default_authorities: @authorities.to_json)
  end

  # responds with js callback
  def destroy
    @authorities.reject! { |auth| auth['seqno'] == params[:id].to_i }
    @ingestible.update!(default_authorities: @authorities.to_json)
    @li_id = "#ia#{params[:id]}"
  end

  private

  def set_ingestible
    @ingestible = Ingestible.find(params[:ingestible_id])
    @authorities = @ingestible.default_authorities.present? ? JSON.parse(@ingestible.default_authorities) : []
  end
end
