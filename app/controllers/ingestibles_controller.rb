# frozen_string_literal: true

class IngestiblesController < ApplicationController
  include LockIngestibleConcern
  skip_before_action :verify_authenticity_token, only: :create # to allow starting ingestions directly from the task system

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible,
                only: %i(show edit update update_markdown update_toc destroy review ingest edit_toc update_toc_list
                         undo)
  before_action :try_to_lock_ingestible,
                only: %i(show edit update update_markdown destroy review update_toc update_toc_list edit_toc undo)

  DEFAULTS = { title: '', status: 'draft', orig_lang: 'he', default_authorities: [], metadata: {}, comments: '',
               markdown: '' }.freeze
  # GET /ingestibles or /ingestibles.json
  def index
    @locked_ingestibles = Ingestible.where('locked_at > ?', 1.hour.ago)
    @my_ingestibles = @locked_ingestibles.where(locked_by_user_id: current_user.id)
    @locked_ingestibles = @locked_ingestibles.where.not(id: @my_ingestibles)

    @other_ingestibles = Ingestible.where.not(id: @locked_ingestibles.pluck(:id)).order(updated_at: :desc).page(params[:page])
  end

  # GET /ingestibles/1 or /ingestibles/1.json
  def show
    # before ingestion, editing is the meaningful view
    unless @ingestible.ingested?
      edit
      render :edit
    else
      @changes = JSON.parse(@ingestible.ingested_changes)
    end
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

  # GET /ingestibles/1/undo
  def undo
    changes = JSON.parse(@ingestible.ingested_changes)
    @collection = changes['collections'].present? ? Collection.find(changes['collections'].first[0]) : nil
    changes['texts'].each do |id, title, authorstr|
      m = Manifestation.find(id)
      @collection.collection_items.where(item: m).destroy_all unless @collection.nil?
      m.destroy!
    end
    changes['placeholders'].each do |x|
      @collection.collection_items.where(alt_title: x).destroy_all unless @collection.nil?
    end
    # delete the collection IF this ingestion created it AND there are no more items in it (now that we have deleted the ones this ingestion added)
    @collection.destroy! if @collection.present? && changes['collections'].first[2] == 'created' && @collection.collection_items.empty?
    @ingestible.draft!
    redirect_to edit_ingestible_url(@ingestible), notice: t('.undone')
  end

  # GET /ingestibles/1/ingest
  def ingest
    prep_for_ingestion
    if @errors
      @ingestible.draft! unless @ingestible.draft?
      redirect_to review_ingestible_url(@ingestible), alert: t('.errors')
    elsif @authorities_tbd.present?
      @ingestible.awaiting_authorities!
      redirect_to ingestibles_path, alert: t('.ingestion_now_pending')
    else
      @failures = []
      @changes = { placeholders: [], texts: [], collections: [] }
      create_or_load_collection unless @ingestible.no_volume # no_volume means we don't want to ingest into a Collection, and @collection would be nil.
      # - loop over whole TOC
      i = 0
      @decoded_toc.each do |x|
        if x[0] == 'yes' # a text to ingest
          upload_text(x, i)
          i += 1
        else # a placeholder
          create_placeholder(x) unless @ingestible.no_volume # placeholders only make sense in volumes
        end
      end
      @ingestible.ingested_changes = @changes.to_json # record all IDs in ingestible, for undoability
      @ingestible.user = current_user # record ingesting user
      if @failures.present?
        @ingestible.status = 'failed'
        @ingestible.problem = '' if @ingestible.problem.nil?
        @ingestible.problem += @failures.join("\n")
        @ingestible.save!
        redirect_to review_ingestible_url(@ingestible), alert: t('.failures')
      else
        @ingestible.status = 'ingested'
        @ingestible.save!
        # - email (whom?) with news about the ingestion, and links to all the created entities
        # - show post-ingestion screen, with links to all created entities and affected authorities
        Rails.cache.delete('whatsnew_anonymous') # trigger an updating of whatsnew
        redirect_to ingestibles_url, notice: t('.success')
      end
    end
  end

  # GET /ingestibles/1/edit
  def edit
    @ingestible.update_parsing # refresh markdown or text buffers if necessary
    prep(true) # rendering of HTML needed for editing screen
  end

  # POST /ingestibles or /ingestibles.json
  def create
    # TODO: use params to set defaults (callable from the tasks system, which means we can populate the title (=task name), genre, credits)
    @ingestible = Ingestible.new(ingestible_params)
    @ingestible.credits.gsub!(/\s*;\s*/, "\n") if @ingestible.credits.present?
    @ingestible.update_authorities_and_metadata_from_volume if @ingestible.prospective_volume_id.present?
    if params[:ingestible][:originating_task].present?
      existing = Ingestible.where(originating_task: params[:ingestible][:originating_task])
      if existing.present?
        redirect_to edit_ingestible_url(existing.first), notice: t('ingestible.already_being_ingested')
        return
      end
    end
    if params[:docx].present?
      file = URI.open(params[:docx])
      uri = URI.parse(params[:docx])
      @ingestible.docx.attach(io: file, filename: CGI.unescape(File.basename(uri.path)))
    end
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
        @ingestible.update_authorities_and_metadata_from_volume
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
    toc_params = params.permit(%i(title new_title genre orig_lang intellectual_property authority_id authority_name
                                  role new_person_tbd rmauth seqno))
    cur_toc = @ingestible.decode_toc
    updated = false
    prep(false) # prepare the markdown titles for the view
    cur_toc.each do |x|
      next unless x[1] == params[:title] # update the existing entry

      x[1] = toc_params[:new_title] if toc_params[:new_title].present? # allow changing the title
      x[3] = toc_params[:genre] if toc_params[:genre].present?
      x[4] = toc_params[:orig_lang] if toc_params[:orig_lang].present?
      x[5] = toc_params[:intellectual_property] if toc_params[:intellectual_property].present?

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
               " #{include ? 'yes' : 'no'} || #{x} || || #{@ingestible.genre} || #{@ingestible.orig_lang} || #{@ingestible.intellectual_property}" # use ingestible defaults when set
             else
               " #{include ? 'yes' : 'no'} || #{x} || #{existing[2]} || #{existing[3]} || #{existing[4]} || #{existing[5]}" # preserve any existing metadata
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

  def prep(render_html = false)
    markdown = @ingestible.markdown.presence || ''
    @markdown_titles = markdown.scan(/^&&&\s+(.+?)\s*\n/).map(&:first)
    @html = MarkdownToHtml.call(markdown) if render_html
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
    @extraneous_markdown = @markdown_titles - @texts_to_upload.map(&:second)
    @missing_genre = []
    @missing_origlang = []
    @missing_authority = []
    @missing_publisher_info = !@ingestible.no_volume && (@ingestible.publisher.blank? || @ingestible.year_published.blank?)
    @authorities_tbd = []
    @missing_translators = []
    @missing_authors = []
    @texts_to_upload.each do |x|
      @missing_in_markdown << x[1] unless @markdown_titles.include?(x[1])
      @missing_genre << x[1] if x[3].blank?
      aus = if x[2].present?
              JSON.parse(x[2])
            elsif @ingestible.default_authorities.present?
              JSON.parse(@ingestible.default_authorities)
            else
              []
            end
      @missing_authority << x[1] if aus.empty?
      seen_translator = false
      seen_author = false
      aus.each do |ia|
        @authorities_tbd << ia if ia['new_person'].present?
        seen_translator = true if ia['role'] == 'translator'
        seen_author = true if ia['role'] == 'author'
        name = ia['new_person'].presence || ia['authority_name']
        role = ia['role']
        @authority_changes[name] = {} unless @authority_changes.key?(name)
        @authority_changes[name][role] = [] unless @authority_changes[name].key?(role)
        @authority_changes[name][role] << x[1]
      end
      @missing_translators << x[1] if x[4] != 'he' && !seen_translator
      @missing_origlang << x[1] if x[4].blank? || (x[4] == 'he' && seen_translator)
      @missing_authors << x[1] unless seen_author
    end
    @errors = @missing_in_markdown.present? || @extraneous_markdown.present? || @missing_genre.present? || @missing_origlang.present? || @missing_authority.present? || @missing_translators.present? || @missing_authors.present? || @missing_publisher_info
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
      :intellectual_property,
      :periodical_id,
      :docx,
      :metadata,
      :comments,
      :no_volume,
      :attach_photos,
      :problem,
      :prospective_volume_id,
      :prospective_volume_title,
      :pub_link,
      :pub_link_text,
      :toc_buffer,
      :credits,
      :originating_task
    )
  end

  def create_or_load_collection
    created_volume = false
    if @ingestible.prospective_volume_id.present?
      if @ingestible.prospective_volume_id[0] == 'P' # new volume from known Publication
        @publication = Publication.find(@ingestible.prospective_volume_id[1..-1])
        @collection = Collection.find_by(publication: @publication) # might have been created by another ingestion while we we working on this, after identifying the publication...
        if @collection.nil? # new volume from known Publication
          @collection = Collection.create!(title: @publication.title,
                                           collection_type: 'volume', publication: @publication,
                                           publisher_line: @publication.publisher_line, pub_year: @publication.pub_year)
          created_volume = true
        end
      else # existing volume
        @collection = Collection.find(@ingestible.prospective_volume_id)
      end
    else # new volume from scratch!
      @collection = Collection.create!(title: @ingestible.prospective_volume_title, collection_type: 'volume',
                                       pub_year: @ingestible.year_published, publisher_line: @ingestible.publisher)
      created_volume = true
    end
    if @ingestible.publisher.present? && @collection.publisher_line.blank? # populate publisher info if not already set (e.g. in new periodical issue)
      @collection.publisher_line = @ingestible.publisher
      @collection.pub_year = @ingestible.year_published
    end
    creds = @collection.credits.presence || ''
    creds += "\n" + @ingestible.credits if @ingestible.credits.present?
    credits = creds.lines.map(&:strip).uniq.join("\n")
    @collection.credits = credits
    @collection.save!
    @changes[:collections] << [@collection.id, @collection.title, created_volume ? 'created' : 'updated'] # record the new volume for the post-ingestion screen
    return unless created_volume

    return unless @ingestible.default_authorities

    JSON.parse(@ingestible.default_authorities).each do |auth|
      @collection.involved_authorities.create!(authority: Authority.find(auth['authority_id']),
                                               role: auth['role'])
    end
  end

  # determine period by most common one among relevant involved authorities
  def determine_period_by_involved_authorities(ids)
    periods = []
    Authority.find(ids).each do |a|
      periods << a.person.period if a.person.present?
    end
    return periods.present? ? periods.max_by { |i| periods.count(i) } : nil
  end

  # status defaults to published, but if even one authority is unpublished, text will be unpublished
  def determine_publication_status_by_involved_authorities(ids)
    status = :published
    Authority.find(ids).each do |a|
      status = :unpublished unless a.published?
    end
    status
  end

  # add a placeholder (itemless CollectionItem) to the collection
  def create_placeholder(toc_line)
    return if @collection.collection_items.where(alt_title: toc_line[1]).present? # don't create duplicate placeholders. It is expected they are unique within the collection. Genuine duplicate titles that the user DOES want created should have been disambiguated at the review phase.

    @collection.append_collection_item(CollectionItem.new(alt_title: toc_line[1]))
    @changes[:placeholders] << toc_line[1]
  end

  def upload_text(toc_line, index)
    # create Work, Expression, Manifestation entities

    Chewy.strategy(:atomic) do
      ActiveRecord::Base.transaction do
        w = Work.new(
          title: toc_line[1],
          orig_lang: toc_line[4],
          genre: toc_line[3],
          primary: true # TODO: un-hardcode primariness when ingestible TOC editing supports it
        )
        author_names = []
        author_ids = []
        translator_names = []
        translator_ids = []
        other_authorities = []
        auths = if toc_line[2].present?
                  JSON.parse(toc_line[2])
                elsif @ingestible.default_authorities.present?
                  JSON.parse(@ingestible.default_authorities)
                else
                  []
                end
        auths.each do |ia|
          if ia['role'] == 'author'
            author_names << ia['authority_name']
            author_ids << ia['authority_id']
          elsif ia['role'] == 'translator'
            translator_names << ia['authority_name']
            translator_ids << ia['authority_id']
          else
            other_authorities << [ia['authority_id'], ia['role']]
          end
        end
        period = determine_period_by_involved_authorities(w.orig_lang == 'he' ? author_ids : translator_ids) # translator's period is the relevant one for translations
        pub_status = determine_publication_status_by_involved_authorities(author_ids + translator_ids + other_authorities.map(&:first))
        e = w.expressions.build(
          title: toc_line[1],
          language: 'he',
          period: period, # what to do if corporate body?
          intellectual_property: toc_line[5],
          source_edition: @ingestible.publisher,
          date: @ingestible.year_published
        )
        authors = auths.select { |ia| ia['role'] == 'author' }.map { |ia| ia['authority_name'] }
        translators = auths.select { |ia| ia['role'] == 'translator' }.map { |ia| ia['authority_name'] }.join(', ')
        responsibility_line = translators.present? ? translator_names.join(', ') : authors.join(', ')
        # the_markdown = @ingestible.markdown.scan(/^&&&\s+#{toc_line[1]}\s*\n(.+?)(?=\n&&&|$)/m).first.first
        m = e.manifestations.build(
          title: toc_line[1],
          responsibility_statement: responsibility_line,
          conversion_verified: true,
          medium: I18n.t(:etext),
          publisher: Rails.configuration.constants['our_publisher'],
          publication_place: Rails.configuration.constants['our_place_of_publication'],
          publication_date: Time.zone.today,
          markdown: @ingestible.texts[index].content,
          status: pub_status,
          credits: @ingestible.credits.lines.map(&:strip).uniq.join("\n")
        )
        w.save!
        auths = []
        # associate authorities
        Authority.find(author_ids).each do |a|
          w.involved_authorities.create!(authority: a, role: :author)
          auths << a
        end
        Authority.find(translator_ids).each do |a|
          e.involved_authorities.create!(authority: a, role: :translator)
          auths << a
        end
        Authority.find(other_authorities.map(&:first)).each_with_index do |auth, i|
          e.involved_authorities.create!(authority: auth, role: other_authorities[i][1])
          auths << auth
        end
        auths.uniq.each { |a| a.invalidate_cached_credits! }
        @changes[:texts] << [m.id, m.title, m.responsibility_statement]
        m.recalc_cached_people!
        if @ingestible.pub_link.present? && @ingestible.pub_link_text.present?
          m.external_links.create!(linktype: :publisher_site, url: @ingestible.pub_link,
                                   description: @ingestible.pub_link_text)
        end

        unless @ingestible.no_volume
          # finally, add to collection, replacing placeholder if appropriate
          placeholder = @collection.collection_items.where(alt_title: toc_line[1], item: nil)
          if placeholder.present? # we will replace the placeholder if it exists
            placeholder_seqno = placeholder.first.seqno
            @collection.append_collection_item(CollectionItem.new(item: m, seqno: placeholder_seqno))
            placeholder.destroy_all if placeholder.present? # delete old placeholder, now replaced by the actual text
          else
            @collection.append_item(m) # append the new text to the (current) end of the collection if there were no placeholders already
          end
        end
      end # transaction
    end # Chewy strategy
  rescue StandardError
    @failures << "#{toc_line[1]} - #{$!}"
    return I18n.t(:frbrization_error)
  end
end
