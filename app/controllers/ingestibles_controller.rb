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
    @markdown_titles = @ingestible.markdown.scan(/^&&&\s+(.+?)\s*\n/).map(&:first)
    prep_for_ingestion
  end

  # GET /ingestibles/1/ingest
  def ingest
    prep_for_ingestion
    if @errors
      redirect_to review_ingestible_url(@ingestible), alert: t('.errors')
    else
      @collection = nil # default
      @collection = create_or_load_collection unless no_volume # no_volume means we don't want to ingest into a Collection

      # - loop over whole TOC
      # - create placeholders
      # - create Work, Expression, Manifestation entities
      # - associate authorities
      # - add to collection, replacing placeholder if appropriate
      # - record all IDs in ingestible, for undoability
      # - record ingesting user
      # - email (whom?) with news about the ingestion, and links to all the created entities
      # - show post-ingestion screen, with links to all created entities and affected authorities
      # - trigger an updating of whatsnew

      redirect_to ingestibles_url, notice: t('.success')
    end
  end

  # GET /ingestibles/1/edit
  def edit
    @ingestible.update_parsing # refresh markdown or text buffers if necessary
    prep
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
    existing_volume_id = @ingestible.volume_id
    existing_prospective_volume_id = @ingestible.prospective_volume_id
    if @ingestible.update(ingestible_params)
      if existing_volume_id != @ingestible.volume_id || existing_prospective_volume_id != @ingestible.prospective_volume_id
        @ingestible.update_authorities_from_volume
      end
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
    toc_params = params.permit(%i(title genre orig_lang authority_id authority_name role new_person_tbd rmauth seqno))
    cur_toc = @ingestible.decode_toc
    updated = false

    cur_toc.each do |x|
      next unless x[0] == 'yes' && x[1] == params[:title] # update the existing entry

      x[3] = toc_params[:genre] if toc_params[:genre].present?
      x[4] = toc_params[:orig_lang] if toc_params[:orig_lang].present?

      if params[:new_person_tbd].present? or params[:authority_id].present?
        authorities = x[2].present? ? JSON.parse(x[2]) : []
        highest_seqno = authorities.pluck('seqno').max || 0
        new_authority = { 'seqno' => highest_seqno + 1, 'role' => params[:role] }
        if params[:new_person_tbd].present?
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
      elsif params[:rmauth].present?
        authorities = x[2].present? ? JSON.parse(x[2]) : []
        authorities.reject! { |a| a['seqno'] == params[:seqno].to_i }
        x[2] = authorities.to_json
      end

      updated = true
      break
    end
    return unless updated

    prep
    @ingestible.update_columns(toc_buffer: @ingestible.encode_toc(cur_toc))
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
               " #{include ? 'yes' : 'no'} || #{x} || || #{@ingestible.genre} || #{@ingestible.orig_lang}" # use ingestible defaults when set
             else
               " #{include ? 'yes' : 'no'} || #{x} || || #{existing[2]} || #{existing[3]}" # preserve any existing metadata
             end
    end
    @ingestible.update_columns(toc_buffer: ret.join("\n"))
    redirect_to edit_ingestible_url(@ingestible), notice: t('updated_successfully'), status: :see_other
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

  def prep
    @html = MarkdownToHtml.call(@ingestible.markdown)
    @markdown_titles = @ingestible.markdown.scan(/^&&&\s+(.+?)\s*\n/).map(&:first)
  end

  # this method prepares the ingestible for ingestion:
  # it collects the placeholders to be created according to the toc,
  # it collects the manifestations to be created for the included texts,
  # and it maps the affected involved authorities.
  # It is called by the review action for the user's approval, but also from the actual ingestion action.
  def prep_for_ingestion
    @decoded_toc = @ingestible.decode_toc
    @texts_to_upload = @ingestible.texts_to_upload
    @placeholders = @ingestible.placeholders
    @markdown_titles = @ingestible.markdown.scan(/^&&&\s+(.+?)\s*\n/).map(&:first)
    @collection = @ingestible.volume # would be nil for new volumes
    @authority_changes = {}
    @missing_in_markdown = []
    @missing_genre = []
    @missing_origlang = []
    @missing_authority = []
    @ingestible.volu
    @texts_to_upload.each do |x|
      @missing_in_markdown << x[1] unless @markdown_titles.include?(x[1])
      @missing_genre << x[1] if x[3].blank?
      @missing_origlang << x[1] if x[4].blank?
      aus = if x[2].present?
              JSON.parse(x[2])
            elsif @ingestible.default_authorities.present?
              JSON.parse(@ingestible.default_authorities)
            else
              []
            end
      @missing_authority << x[1] if aus.empty?
      aus.each do |ia|
        name = ia['new_person'].presence || ia['authority_name']
        role = ia['role']
        @authority_changes[name] = {} unless @authority_changes.key?(name)
        @authority_changes[name][role] = [] unless @authority_changes[name].key?(role)
        @authority_changes[name][role] << x[1]
      end
    end
    @errors = @missing_in_markdown.present? || @missing_genre.present? || @missing_origlang.present? || @missing_authority.present?
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

  def create_or_load_collection
    created_volume = false
    if @ingestible.prospective_volume_id.present?
      if @ingestible.prospective_volume_id[0] == 'P' # new volume from known Publication
        @publication = Publication.find(@ingestible.prospective_volume_id[1..-1])
        @collection = Collection.create!(title: @ingestible.prospective_volume_title,
                                         collection_type: 'volume', publication: @publication)
        created_volume = true
      else # existing volume
        @collection = Collection.find(@ingestible.prospective_volume_id)
      end
    else # new volume from scratch!
      @collection = Collection.create!(title: @ingestible.prospective_volume_title, collection_type: 'volume')
      created_volume = true
    end
    return unless created_volume

    @ingestible.default_authorities.each do |auth|
      @collection.involved_authorities.create!(authority: Authority.find(auth['authority_id']),
                                               role: auth['role'])
    end
  end
end
