# frozen_string_literal: true

class IngestiblesController < ApplicationController
  include LockIngestibleConcern

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible,
                only: %i(show edit update update_markdown update_toc destroy review edit_toc update_toc_list)
  before_action :try_to_lock_ingestible,
                only: %i(show edit update update_markdown destroy review update_toc update_toc_list edit_toc)

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
    @markdown_titles = @ingestible.markdown.scan(/^&&&\s+(.+?)\s*\n/).map(&:first)
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

  def edit_toc
    include = false
    toc_buf = []
    @ingestible.decode_toc.each do |x|
      if include && x[0].strip != 'yes'
        include = false
        toc_buf << '$$$ סוף'
      end
      if !include && x[0].strip == 'yes'
        include = true
        toc_buf << '$$$ התחלה'
      end
      toc_buf << x[1]
    end
    @toc_list = toc_buf.join("\n")
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

  def update_toc
    toc_params = params.permit(%i(title genre orig_lang))
    cur_toc = @ingestible.decode_toc
    updated = false
    cur_toc.each do |x|
      next unless x[0] == 'yes' && x[1] == params[:title] # update the existing entry

      x[4] = toc_params[:genre]
      x[5] = toc_params[:orig_lang]

      add_auth = params[:new_person].present? or params[:authority_id].present?
      if add_auth
        authorities = JSON.parse(x[2] || '[]')
        highest_seqno = authorities.pluck('seqno').max || 0
        new_authority = { 'seqno' => highest_seqno + 1, 'role' => params[:role] }
        if params[:new_person].present?
          # Authority not yet present in database
          new_authority['new_person'] = params[:new_person_tbd]
        elsif params[:authority_id].present?
          # Existing authority from database
          new_authority['authority_id'] = params[:authority_id].to_i
          new_authority['authority_name'] = params[:authority_name]
        else
          head :bad_request
          return
        end
        authorities << new_authority
        x[2] = authorities.to_json
      end

      updated = true
      break
    end
    if updated
      @ingestible.update_columns(toc_buffer: @ingestible.encode_toc(cur_toc))
    end
    head :ok
  end

  def update_toc_list
    toc_list = params[:toc_list].split("\n").map(&:strip)
    ret = []
    cur_toc = @ingestible.decode_toc
    include = false
    toc_list.each do |x|
      next if x.blank?

      if x =~ /^\$\$\$ /
        include = x == '$$$ התחלה'
        next
      end
      existing = cur_toc.find { |y| y[1].strip == x }

      ret << if existing.nil?
               " #{include ? 'yes' : 'no'} || #{x} || #{@ingestible.genre} || #{@ingestible.orig_lang}" # use ingestible defaults when set
             else
               " #{include ? 'yes' : 'no'} || #{x} || #{existing[2]} || #{existing[3]}" # preserve any existing metadata
             end
    end
    @ingestible.update_columns(toc_buffer: ret.join("\n"))
    edit
    render :edit
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
      :prospective_volume_title,
      :toc_buffer
    )
  end
end
