# frozen_string_literal: true

class IngestiblesController < ApplicationController
  include LockIngestibleConcern

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible, only: %i(show edit update destroy addauth rmauth)
  before_action :try_to_lock_ingestible, only: %i(show edit update destroy addauth rmauth)

  DEFAULTS = { title: '', status: 'draft', orig_lang: 'he', default_authorities: [], metadata: {}, comments: '',
               markdown: '' }.freeze
  # GET /ingestibles or /ingestibles.json
  def index
    @ingestibles = Ingestible.all
  end

  # GET /ingestibles/1 or /ingestibles/1.json
  def show
    edit
    render :edit
  end

  # GET /ingestibles/new
  def new
    @ingestible = Ingestible.new(DEFAULTS)
  end

  # GET /ingestibles/1/edit
  def edit
    @ingestible.update_parsing # refresh markdown or text buffers if necessary
  end

  # POST /ingestibles or /ingestibles.json
  def create
    # TODO: use params to set defaults (callable from the tasks system, which means we can populate the title (=task name), genre, credits)
    @ingestible = Ingestible.new(ingestible_params)

    if @ingestible.save
      redirect_to edit_ingestible_url(@ingestible), notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def addauth
    @auths = @ingestible.default_authorities.present? ? JSON.parse(@ingestible.default_authorities) : []
    highest_seqno = @auths.pluck('seqno').max || 0
    h = { 'seqno' => highest_seqno + 1, 'role' => params[:role] }
    if params[:new_person].present?
      h['new_person'] = params[:new_person]
    else
      h['authority_id'] = params[:authority_id]
      h['authority_name'] = params[:authority_name]
    end
    @auths << h
    @ingestible.update!(default_authorities: @auths.to_json)
    respond_to do |format|
      format.js # addauth.js.erb
    end
  end

  def rmauth
    @auths = @ingestible.default_authorities.present? ? JSON.parse(@ingestible.default_authorities) : []
    @auths.delete_if { |auth| auth['seqno'] == params[:seqno].to_i }
    @ingestible.update!(default_authorities: @auths.to_json)
    @li_id = "#ia#{params[:seqno]}"
    respond_to do |format|
      format.js # rmauth.js.erb
    end
  end

  # PATCH/PUT /ingestibles/1 or /ingestibles/1.json
  def update
    if @ingestible.update(ingestible_params)
      flash.now.notice = t('.success')
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /ingestibles/1 or /ingestibles/1.json
  def destroy
    @ingestible.destroy
    redirect_to ingestibles_url, notice: t('.success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ingestible
    @ingestible = Ingestible.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ingestible_params
    params.require(:ingestible).permit(
      :title,
      :status,
      :scenario,
      :genre,
      :publisher,
      :year_published,
      :orig_lang,
      :docx,
      :metadata,
      :comments,
      :markdown,
      :no_volume,
      :insert_cid,
      :attach_photos
    )
  end
end
