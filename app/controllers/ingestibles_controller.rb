# frozen_string_literal: true

class IngestiblesController < ApplicationController
  include LockIngestibleConcern

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible, only: %i(show edit update update_markdown destroy review)
  before_action :try_to_lock_ingestible, only: %i(show edit update update_markdown destroy review)

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

  # GET /ingestibles/1/review
  def review
  end

  # GET /ingestibles/1/edit
  def edit
    @ingestible.update_parsing # refresh markdown or text buffers if necessary
    @html = MarkdownToHtml.call(@ingestible.markdown)
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

  # PATCH/PUT /ingestibles/1 or /ingestibles/1.json
  def update
    if @ingestible.update(ingestible_params)
      redirect_to edit_ingestible_url(@ingestible), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_markdown
    markdown_params = params.require(:ingestible).permit(:markdown)
    @ingestible.update!(markdown_params)
    redirect_to edit_ingestible_url(@ingestible), notice: t(:updated_successfully)
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
      :no_volume,
      :attach_photos,
      :prospective_volume_id,
      :toc_buffer
    )
  end
end
