require 'pandoc-ruby'

class ManifestationController < ApplicationController
  # class WorkSearch < FortyFacets::FacetSearch
  #   model 'Manifestation' # which model to search for
  #   text :title   # filter by a generic string entered by the user
  #   # scope :classics   # only return movies which are in the scope 'classics'
  #   # range :price, name: 'Price' # filter by ranges for decimal fields
  #   facet :created_at, name: 'pub_date' # , order: :year # additionally order values in the year field
  #   facet [:expressions], :language
  #   facet [:expressions], :genre #, name: 'Genre' # generate a filter with all values of 'genre' occuring in the result
  #   #facet [:studio, :country], name: 'Country' # generate a filter several belongs_to 'hops' away

  #   # orders 'Title' => :title, 'price, cheap first' => "price asc", 'price, expensive first' => {price: :desc, title: :desc}
  #   #custom :for_manual_handling
  # end

  before_action only: [:list, :show, :remove_link, :edit_metadata] do |c| c.require_editor('edit_catalog') end
  before_action only: [:edit, :update] do |c| c.require_editor(['edit_catalog', 'conversion_verification', 'handle_proofs']) end
  before_action only: [:all, :genre, :period, :by_tag] do |c| c.refuse_unreasonable_page end
  autocomplete :manifestation, :title, limit: 20, display_value: :title_and_authors, full: true
  autocomplete :person, :name, :limit => 2, full: true
  autocomplete :tag, :name

  #impressionist :actions=>[:read,:readmode, :print, :download] # log actions for pageview stats

  #layout false, only: [:print]

  DATE_FIELD = {'uploaded' => 'manifestations.created_at', 'created' => 'works.normalized_creation_date', 'published' => 'expressions.normalized_pub_date'}
  #############################################
  # public actions
  def all
    @page_title = t(:all_works)+' '+t(:project_ben_yehuda)
    @pagetype = :works
    # @collection = Manifestation.all_published.limit(100)
    # @collection = Manifestation.all_published
    @works_list_title = t(:works_list)
    # update the total works count cache if stale, because specifically in "all works" view, the discrepancy is painful
    fresh_count = Manifestation.all_published.count
    if fresh_count != Manifestation.cached_count
      Rails.cache.write("m_count", Manifestation.all_published.count, expires_in: 24.hours)
    end
    browse
  end

  def browse
    @pagetype = :works
    @works_list_title = t(:works_list) # TODO: adjust by query
    prep_for_browse
    prep_user_content(:manifestation)
    render :browse
    respond_to do |format|
      format.html
      format.js
    end
  end

  def translations
    @page_title = t(:translations)+' '+t(:project_ben_yehuda)
    params['ckb_languages'] = ['xlat']
    browse
  end

  def remove_bookmark
    if current_user
      @m = Manifestation.find(params[:id])
      unless @m.nil?
        Bookmark.where(manifestation: @m, user: current_user).first.destroy
      end
    end
    head :ok
  end
  def set_bookmark
    if current_user
      @m = Manifestation.find(params[:id])
      unless @m.nil?
        @b = Bookmark.where(manifestation: @m, user: current_user)
        if @b.empty?
          @b = Bookmark.new(manifestation: @m, user: current_user)
        else
          @b = @b.first
        end
        @b.bookmark_p = params[:bookmark_path]
        @b.save
        respond_to do |format|
          format.js
        end
        render partial: 'set_bookmark'
      else
        head :ok
      end
    else
      head :ok
    end
  end
  def by_tag
    @page_title = t(:works_by_tag)+' '+t(:project_ben_yehuda)
    @pagetype = :works
    @tag = Tag.find(params[:id])
    if @tag
      @collection = Manifestation.all_published.by_tag(params[:id]) # TODO: re-implement within prep_collection
      @works_list_title = t(:works_by_tag)+': '+@tag.name
      browse
    else
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    end
  end

  def autocomplete_works_by_author
    term = params[:term]
    author = params[:author]
    if term && author && !term.blank? && !author.blank?
      items = Person.find(author.to_i).all_works_by_title(term)
    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :title_and_authors, {}), root: false
  end

  def periods # /periods dashboard
    @tabclass = set_tab('periods')
    @page_title = t(:periods)+' - '+t(:project_ben_yehuda)
    @pagetype = :periods
  end

  def works # /works dashboard
    @tabclass = set_tab('works')
    @page_title = t(:works)+' - '+t(:project_ben_yehuda)
    @pagetype = :works
    @work_stats = {total: Manifestation.cached_count, pd: Manifestation.cached_pd_count, translated: Manifestation.cached_translated_count}
    @work_stats[:permission] = @work_stats[:total] - @work_stats[:pd]
    @work_counts_by_genre = Manifestation.cached_work_counts_by_genre
    @pop_by_genre = Manifestation.cached_popular_works_by_genre # get popular works by genre + most popular translated
    @rand_by_genre = {}
    @surprise_by_genre = {}
    get_genres.each do |g|
      @rand_by_genre[g] = Manifestation.randomize_in_genre_except(@pop_by_genre[g][:orig], g) # get random works by genre
      @surprise_by_genre[g] = @rand_by_genre[g].pop # make one of the random works the surprise work
    end
    @works_abc = Manifestation.first_25 # get cached first 25 manifestations
    @new_works_by_genre = Manifestation.cached_last_month_works
    @featured_content = featured_content
    (@fc_snippet, @fc_rest) = @featured_content.nil? ? ['',''] : snippet(@featured_content.body, 500) # prepare snippet for collapsible
    @popular_tags = cached_popular_tags
  end

  def whatsnew
    @tabclass = set_tab('works')
    @page_title = t(:whatsnew)
    @whatsnew = []
    @anonymous = true
    if params['months'].nil? or params['months'].empty?
      @whatsnew = whatsnew_anonymous
    else
      @whatsnew = whatsnew_since(params[:months].to_i.months.ago)
      @anonymous = false
    end
    @new_authors = Person.new_since(1.month.ago)
  end

  def like
    unless current_user.nil?
      @m = Manifestation.find(params[:id])
      @m.likers << current_user unless @m.likers.include?(current_user)
    end
    head :ok
  end

  def unlike
    unless current_user.nil?
      @m = Manifestation.find(params[:id])
      @m.likers.delete(current_user) # safely fails if already deleted
    end
    head :ok
  end

  def dict
    @m = Manifestation.joins(:expressions).includes(:expressions).find(params[:id])
    if @m.nil?
      head :not_found
    else
      if @m.expressions[0].genre != 'lexicon'
        redirect_to action: 'read', id: @m.id
      else
        @page = params[:page] || 1
        @page = 1 if ['0',''].include?(@page) # slider sets page to zero or '', awkwardly
        @dict_list_mode = params[:dict_list_mode] || 'list'
        @emit_filters = true if params[:load_filters] == 'true' || params[:emit_filters] == 'true'
        @e = @m.expressions[0]
        @header_partial = 'manifestation/dict_top'
        @pagetype = :manifestation
        @entity = @m
        @all_headwords = DictionaryEntry.where(manifestation_id: @m.id)
        unless params[:page].nil? || params[:page].empty?
          params[:to_letter] = nil # if page was specified, forget the to_letter directive
        end
        oldpage = @page
        nonnil_headwords = DictionaryEntry.select(:sequential_number, :sort_defhead).where("manifestation_id = #{@m.id} and defhead is not null").order(sequential_number: :asc) # use paging to calculate first/last in sequence, to allow pleasing lists of 100 items each, no matter how many skipped headwords there are
        @total_headwords = nonnil_headwords.length
        @headwords_page = nonnil_headwords.page(@page)
        @total_pages = @headwords_page.total_pages
        unless params[:to_letter].nil? || params[:to_letter].empty? # for A-Z navigation, we need to adjust the page
          adjust_page_by_letter(nonnil_headwords, params[:to_letter], :sort_defhead, nil, false)
          @headwords_page = nonnil_headwords.page(@page) if oldpage != @page # re-get page X of manifestations if adjustment was made
        end
    
        @total = @total_headwords # needed?
        @filters = []
        if @headwords_page.count == 0
            first_seqno = 9
            last_seqno = 1 # safely generate zero results in following query
        else
          first_seqno = @headwords_page.first.sequential_number
          last_seqno = @headwords_page.last.sequential_number
        end
        @headwords = DictionaryEntry.where("manifestation_id = #{@m.id} and sequential_number >= #{first_seqno} and sequential_number <= #{last_seqno}").order(sequential_number: :asc)
        @ab = prep_ab(@all_headwords, @headwords_page, :sort_defhead)
      end
    end
  end

  def dict_entry
    @entry = DictionaryEntry.find(params[:entry])
    @m = Manifestation.find(params[:id])
    if @entry.nil? || @m.nil?
      head :not_found
    else
      @header_partial = 'manifestation/dict_entry_top'
      @pagetype = :manifestation
      @entity = @m
      @e = @m.expressions[0]
      @prev_entries = @entry.get_prev_defs(5)
      @next_entries = @entry.get_next_defs(5)
      @prev_entry = @prev_entries[0] # may be nil if at beginning of dictionary
      @next_entry = @next_entries[0] # may be nil if at [temporary] end of dictionary
      @skipped_to_prev = @prev_entry.nil? ? 0 : @entry.sequential_number - @prev_entry.sequential_number - 1
      @skipped_to_next = @next_entry.nil? ? 0 : @next_entry.sequential_number - @entry.sequential_number - 1
      @incoming_links = @entry.incoming_links.includes(:incoming_links)
      @outgoing_links = @entry.outgoing_links.includes(:outgoing_links)
    end
  end
  def read
    @m = Manifestation.joins(:expressions).includes(:expressions).find(params[:id])
    if @m.nil?
      head :not_found
    else
      if @m.expressions[0].genre == 'lexicon' && DictionaryEntry.where(manifestation_id: @m.id).count > 0
        redirect_to action: 'dict', id: @m.id
      else
        unless @m.published?
          flash[:notice] = t(:work_not_available)
          redirect_to '/'
        else
          prep_for_read
          @proof = Proof.new
          @new_recommendation = Recommendation.new
          @tagging = Tagging.new
          @tagging.manifestation_id = @m.id
          @tagging.suggester = current_user
          @taggings = @m.taggings
          @recommendations = @m.recommendations
          @links = @m.external_links.group_by {|l| l.linktype}
          @random_work = Manifestation.where(id: Manifestation.pluck(:id).sample(5), status: Manifestation.statuses[:published])[0]
          @header_partial = 'manifestation/work_top'
          @works_about = @w.works_about
          @scrollspy_target = 'chapternav'
          prep_user_content(:manifestation)
        end
      end
    end
  end

  def readmode
    @readmode = true
    prep_for_read
  end

  def print
    @print = true
    prep_for_print
    @footer_url = url_for(action: :read, id: @m.id)
  end

  def download
    format = params[:format]
    unless Downloadable.doctypes.include?(format)
      flash[:error] = t(:unrecognized_format)
      redirect_to manifestation_read_path(params[:id])
      return
    end

    # Wrapping download code into transaction to make it atomic
    # Without this we had situation when Downloadable object was created but attachmnt creation failed
    Downloadable.transaction do
      m = Manifestation.find(params[:id])
      impressionist(m) unless is_spider?
      dl = GetFreshManifestationDownloadable.call(m, format)
      redirect_to rails_blob_url(dl.stored_file, disposition: :attachment)
    end
  end

  def render_html
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
  end

  def period
    @pagetype = :works
    # @collection = Manifestation.all_published.joins(:expressions).where(expressions: {period: Person.periods[params[:period]]})
    @works_list_title = t(:works_by_period)+': '+t(params[:period])
    @periods = [params[:period]]
    browse
  end

  def genre
    @pagetype = :works
    # @collection = Manifestation.all_published.joins(:expressions).where(expressions: {genre: params[:genre]})
    @works_list_title = t(:works_by_genre)+': '+helpers.textify_genre(params[:genre])
    @genres = [params[:genre]]
    browse
  end

  # this one is called via AJAX
  def get_random
    work = nil
    unless params[:genre].nil? || params[:genre].empty?
      work = randomize_works_by_genre(params[:genre], 1)[0]
    else
      work = randomize_works(1)[0]
    end
    render partial: 'shared/surprise_work', locals: {passed_mode: params[:mode], manifestation: work, id_frag: params[:id_frag], passed_genre: params[:genre], side: params[:side]}
  end

  def surprise_work
    work = Manifestation.all_published.order(Arel.sql('RAND()')).limit(1)[0]
    render partial: 'surprise_work', locals: {work: work}
  end

  def workshow # temporary action to map to the first manifestation of the work; # TODO: in the future, show something intelligent about multiple expressions per work
    work = Work.find(params[:id])
    unless work.nil?
      m = work.expressions[0].manifestations[0]
      redirect_to action: :read, id: m.id
    else
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    end
  end

  #############################################
  # editor actions

  def remove_image
    @m = Manifestation.find(params[:id])
    did_something = false
    if @m.images.attached?
      rec = @m.images.where(id: params[:image_id])
      unless rec.empty?
        rec[0].purge
        did_something = true
      end
    end
    if did_something
      @img_id = params[:image_id]
      respond_to do |format|
        format.js
      end
    else
      head :ok
    end
  end

  def remove_link
    @m = Manifestation.find(params[:id])
    l = @m.external_links.where(id: params[:link_id])
    unless l.empty?
      l[0].destroy
      flash[:notice] = t(:deleted_successfully)
    else
      flash[:error] = t(:no_such_item)
    end
    redirect_to action: :show, id: params[:id]
  end

  def list
    # calculations
    @page_title = t(:catalog_title)
    @total = Manifestation.count
    # form input
    unless params[:commit].blank?
      session[:mft_q_params] = params.permit([:title, :author, :page]) # make prev. params accessible to view
    else
      session[:mft_q_params] = { title: '', author: '' }
    end
    @urlbase = url_for(action: :show, id:1)[0..-2]
    # DB
    if params[:title].blank? && params[:author].blank?
      @manifestations = Manifestation.includes(expressions: :works).page(params[:page]).order('updated_at DESC')
    else
      if params[:author].blank? # 
        @manifestations = Manifestation.includes(expressions: :works).where('title like ?', '%' + params[:title] + '%').page(params[:page]).order('sort_title ASC')
      elsif params[:title].blank?
        @manifestations = Manifestation.includes(expressions: :works).where('cached_people like ?', "%#{params[:author]}%").page(params[:page]).order('sort_title asc')
      else # both author and title
        @manifestations = Manifestation.includes(expressions: :works).where('manifestations.title like ? and manifestations.cached_people like ?', '%' + params[:title] + '%', '%'+params[:author]+'%').page(params[:page]).order('sort_title asc')
      end
    end
  end

  def show
    @m = Manifestation.find(params[:id])
    @page_title = t(:show)+': '+@m.title_and_authors
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
    @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
    h = @m.legacy_htmlfile
    unless h.nil? or h.url.nil? or h.url.empty?
      @legacy_url = 'https://old.benyehuda.org'+h.url
    end
  end

  def edit
    @m = Manifestation.find(params[:id])
    @page_title = t(:edit_markdown)+': '+@m.title_and_authors
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
    @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
    @markdown = @m.markdown
    h = @m.legacy_htmlfile
    unless h.nil? or h.url.nil? or h.url.empty?
      @legacy_url = 'https://old.benyehuda.org'+h.url
    end
  end

  def edit_metadata
    @m = Manifestation.find(params[:id])
    @page_title = t(:edit_metadata)+': '+@m.title_and_authors
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
  end
  def chomp_period
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    [@m, @e, @w].each { |rec|
      if rec.title[-1] == '.'
        rec.title = rec.title[0..-2]
        rec.save!
      end
    }
  end

  def add_aboutnesses
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    @page_title = t(:add_aboutnesses)+': '+@m.title_and_authors
    @aboutness = Aboutness.new
  end

  def add_images
    @m = Manifestation.find(params[:id])
    prev_count = @m.images.count
    @m.images.attach(params.permit(images: [])[:images])
    new_count = @m.images.count
    flash[:notice] = I18n.t(:uploaded_images, {images_added: new_count - prev_count, total: new_count})
    redirect_to action: :show, id: @m.id
  end

  def update
    @m = Manifestation.find(params[:id])
    # update attributes
    if params[:commit] == t(:save)
      Chewy.strategy(:atomic) {
          if params[:markdown].nil? # metadata edit
          @e = @m.expressions[0] # TODO: generalize?
          @w = @e.works[0] # TODO: generalize!
          @w.title = params[:wtitle]
          @w.genre = params[:genre]
          @w.orig_lang = params[:wlang]
          @w.origlang_title = params[:origlang_title]
          @w.date = params[:wdate]
          @w.comment = params[:wcomment]
          unless params[:add_person_w].blank?
            c = Creation.new(work_id: @w.id, person_id: params[:add_person_w], role: params[:role_w].to_i)
            c.save!
          end
          @e.language = params[:elang]
          @e.genre = params[:genre] # expression's genre is same as work's
          @e.title = params[:etitle]
          @e.date = params[:edate]
          @e.comment = params[:ecomment]
          @e.copyrighted = (params[:public_domain] == 'false' ? true : false) # field name semantics are flipped from param name, yeah
          unless params[:add_person_e].blank?
            r = Realizer.new(expression_id: @e.id, person_id: params[:add_person_e], role: params[:role_e].to_i)
            r.save!
          end
          @e.source_edition = params[:source_edition]
          @e.period = params[:period]
          @m.title = params[:mtitle]
          @m.sort_title = params[:sort_title]
          @m.responsibility_statement = params[:mresponsibility]
          @m.comment = params[:mcomment]
          @m.status = params[:mstatus].to_i
          @m.sefaria_linker = params[:sefaria_linker]
          unless params[:add_url].blank?
            @m.external_links.create!(url: params[:add_url], linktype: params[:link_type].to_i, description: params[:link_description], status: :approved)
          end
          @w.save!
          @e.save!
        else # markdown edit and save
          unless params[:newtitle].nil? or params[:newtitle].empty?
            @e = @m.expressions[0] # TODO: generalize?
            @w = @e.works[0] # TODO: generalize!
            @m.title = params[:newtitle]
            @e.title = params[:newtitle]
            @w.title = params[:newtitle] if @w.orig_lang == @e.language # update work title if work in Hebrew
            @e.save!
            @w.save!
          end
          @m.markdown = params[:markdown]
          @m.conversion_verified = params[:conversion_verified]
        end
        @m.recalc_cached_people
        @m.recalc_heading_lines
        @m.save!
        if current_user.has_bit?('edit_catalog')
          redirect_to action: :show, id: @m.id
        else
          redirect_to controller: :admin, action: :index
        end
        flash[:notice] = I18n.t(:updated_successfully)
      }
    elsif params[:commit] == t(:preview)
      @m = Manifestation.find(params[:id])
      @page_title = t(:edit_markdown)+': '+@m.title_and_authors
      @html = MultiMarkdown.new(params[:markdown]).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
      @markdown = params[:markdown]
      @newtitle = params[:newtitle]

      h = @m.legacy_htmlfile
      unless h.nil? or h.url.nil?
        @legacy_url = 'https://old.benyehuda.org'+h.url
      end
      render action: :edit
    end
  end

  protected

  def es_bfunc(coll, page, l, field, direction) # binary-search function for ab_pagination over an ES collection
    recs = coll.order(field).page(page).objects
    rec = recs.first
    return true if rec.nil?
    c = nil
    i = 0
    reccount = recs.count
    while c.nil? && i < reccount do
      c = rec[field][0] unless rec[field].nil? # unready dictionary definitions will have their sort_defhead (and defhead) nil, so move on
      i += 1
      rec = recs[i]
    end
    c = '' if c.nil?
    if(direction == :desc || direction == 'desc')
      return true if c == l || c < l # already too high a page
      return false
    else
      return true if c == l || c > l # already too high a page
      return false
    end
  end
  def bfunc(coll, page, l, field, direction) # binary-search function for ab_pagination
    recs = coll.order(field).page(page)
    rec = recs.first
    return true if rec.nil?
    c = nil
    i = 0
    reccount = recs.count
    while c.nil? && i < reccount do
      c = rec[field][0] unless rec[field].nil? # unready dictionary definitions will have their sort_defhead (and defhead) nil, so move on
      i += 1
      rec = recs[i]
    end
    c = '' if c.nil?
    if(direction == :desc || direction == 'desc')
      return true if c == l || c < l # already too high a page
      return false
    else
      return true if c == l || c > l # already too high a page
      return false
    end
  end

  def adjust_page_by_letter(coll, l, field, direction, is_es)
    # binary search to find page where letter begins
    ret = (1..@total_pages).bsearch{|page|
      if is_es
        es_bfunc(coll, page, l, field, direction)
      else
        bfunc(coll, page, l, field, direction)
      end
    }
    unless ret.nil?
      ret = ret - 1 unless ret == 1
      @page = ret
    else # bsearch returns nil if last page's bfunc returns false
      @page = @total_pages
    end
  end

  def es_datefield_name_from_datetype(dt)
    case dt
    when 'uploaded'
      return 'pby_publication_date'
    when 'created'
      return 'creation_date'
    when 'published'
      return 'orig_publication_date'
    end
  end

  def build_es_filter_from_filters
    ret = []
    @filters = []
    # periods
    @periods = params['ckb_periods'] if params['ckb_periods'].present?
    if @periods.present?
      ret << {terms: {period: @periods}}
      @filters += @periods.map{|x| [I18n.t(x), "period_#{x}", :checkbox]}
    end
    # genders
    @genders = params['ckb_genders'] if params['ckb_genders'].present?
    if @genders.present?
      ret << {terms: {author_gender: @genders}}
      @filters += @genders.map{|x| [I18n.t(:author)+': '+I18n.t(x), "gender_#{x}", :checkbox]}
    end
    @tgenders = params['ckb_tgenders'] if params['ckb_tgenders'].present?
    if @tgenders.present?
      ret << {terms: {translator_gender: @tgenders}}
      @filters += @tgenders.map{|x| [I18n.t(:translator)+': '+I18n.t(x), "tgender_#{x}", :checkbox]}
    end
    # genres
    @genres = params['ckb_genres'] if params['ckb_genres'].present?
    if @genres.present?
      ret << {terms: {genre: @genres}}
      @filters += @genres.map{|x| [helpers.textify_genre(x), "genre_#{x}", :checkbox]}
    end
    # copyright
    @copyright = params['ckb_copyright'].map{|x| x.to_i} if params['ckb_copyright'].present?
    if @copyright.present?
      cright = @copyright.map{|x| x==0 ? 'false' : 'true'}
      ret << {terms: {copyright_status: cright}}
      @filters += @copyright.map{|x| [helpers.textify_copyright_status(x == 1), "copyright_#{x}", :checkbox]}
    end
    # languages

    if params['ckb_languages'].present?
      if params['ckb_languages'] == ['xlat']
        #ret << {must_not: {term: {orig_lang: 'he'}}}
        #@filters << [I18n.t(:translations), 'lang_xlat', :checkbox]
        @languages = get_langs.reject{|x| x == 'he'}
      else
        @languages = params['ckb_languages'].reject{|x| x == 'xlat'}
      end
      if @languages.present?
        ret << {terms: {orig_lang: @languages}}
        @filters += @languages.map{|x| ["#{I18n.t(:orig_lang)}: #{helpers.textify_lang(x)}", "lang_#{x}", :checkbox]}
      end
    end
    # dates
    @fromdate = params['fromdate'] if params['fromdate'].present?
    @todate = params['todate'] if params['todate'].present?
    @datetype = params['date_type']
    range_expr = {}
    if @fromdate.present?
      range_expr['gte'] = @fromdate
      @filters << ["#{I18n.t('d'+@datetype)} #{I18n.t(:fromdate)}: #{@fromdate}", :fromdate, :text]
    end
    if @todate.present?
      range_expr['lte'] = Date.new(@todate.to_i,12,31).to_s
      @filters << ["#{I18n.t('d'+@datetype)} #{I18n.t(:todate)}: #{@todate}", :todate, :text]
    end
    # multi-select authors
    if params['authors'].present?
      @search_type = 'authorname'
      author_ids = params['authors'].split(',').map{|x| x.to_i}
      ret << {terms: {author_ids: author_ids}}
      @authors = author_ids # .join(',')
      @authors_names = params['authors_names']
      @filters << [I18n.t(:authors_xx, {xx: params['authors_names']}), 'authors', :authorlist]
    end
    datefield = es_datefield_name_from_datetype(@datetype)
    ret << {range: {"#{datefield}" => range_expr }} unless range_expr.empty?
    return ret
  end

  def build_es_query_from_filters
    ret = {}
    if params['search_input'].present? || params['authorstr'].present?
      if (params['search_type'].present? && params['search_type'] == 'authorname') || (params['authorstr'].present? && params['search_input'].empty?)
        #ret['match'] = {author_string: params['authorstr'], default_operator: 'and'}
        ret['query_string'] = {fields: [:author_string], query: params['authorstr'], default_operator: 'and'}
        @authorstr = params['authorstr']
        @search_type = 'authorname'
        @filters << [I18n.t(:author_x, {x: params['authorstr']}), :authors, :text]
      else
        ret['match'] = {title: params['search_input'], default_operator: 'and'}
        @search_type = 'workname'
        @filters << [I18n.t(:title_x, {x: params['search_input']}), :search_input, :text]
      end
      @search_input = params['search_input']
    end
    return ret
  end

  def es_prep_collection
    @sort_dir = :default
    if params[:sort_by].present?
      @sort_or_filter = 'sort'
      @sort = params[:sort_by].dup
      params[:sort_by].sub!(/_(a|de)sc$/,'')
      @sort_dir = $&[1..-1] unless $&.nil?
    end
    # figure out sort order
    if params[:sort_by].present?
      case params[:sort_by]
      when 'alphabetical'
        ord = {sort_title: (@sort_dir == :default ? :asc : @sort_dir)}
      when 'popularity'
        ord = {impressions_count: (@sort_dir == :default ? :desc : @sort_dir)}
      when 'publication_date'
        ord = {orig_publication_date: (@sort_dir == :default ? :asc : @sort_dir)}
      when 'creation_date'
        ord = {creation_date: (@sort_dir == :default ? :asc : @sort_dir)}
      when 'upload_date'
        ord = {pby_publication_date: (@sort_dir == :default ? :desc : @sort_dir)}
      end
    else
      sdir = (@sort_dir == :default ? :asc : @sort_dir)
      @sort = "alphabetical_#{sdir}"
      ord = {sort_title: sdir}
    end
    standard_aggregations = {
      periods: {terms: {field: 'period'}},
      genres: {terms: {field: 'genre'}},
      languages: {terms: {field: 'orig_lang', size: get_langs.count + 1}},
      copyright_status: {terms: {field: 'copyright_status'}},
      author_genders: {terms: {field: 'author_gender'}},
      translator_genders: {terms: {field: 'translator_gender'}},
      author_ids: {terms: {field: 'author_ids', size: 2000}} # We may need to increase this threshold in future if number of authors exceeds 2000
    }
    filter = build_es_filter_from_filters
    es_query = build_es_query_from_filters
    es_query = {match_all: {}} if es_query == {}
    @collection = ManifestationsIndex.query(es_query).filter(filter).aggregations(standard_aggregations).order(ord).limit(100) # prepare ES query
    @total = @collection.count # actual query triggered here

    @page = params[:page].to_i
    @page = 1 if @page == 0 # slider sets page to zero, awkwardly
    if @page > (@total/100.0).ceil && @page != 1 # a zero-result query would trigger this, otherwise
      # Sometimes we receive requests to pages with extremely large number from bots/search crawlers
      # So simply respond with NotFound in this case
      raise PageNotFound
    end

    @emit_filters = true if params[:load_filters] == 'true' || params[:emit_filters] == 'true'
    @total = @collection.count # actual query triggered here
    @gender_facet = es_buckets_to_facet(@collection.aggs['author_genders']['buckets'], Person.genders)
    @tgender_facet = es_buckets_to_facet(@collection.aggs['translator_genders']['buckets'], Person.genders)
    @period_facet = es_buckets_to_facet(@collection.aggs['periods']['buckets'], Expression.periods)
    @genre_facet = es_buckets_to_facet(@collection.aggs['genres']['buckets'], get_genres.to_h {|g| [g,g]})
    @language_facet = es_buckets_to_facet(@collection.aggs['languages']['buckets'], get_langs.to_h {|l| [l,l]})
    @language_facet[:xlat] = @language_facet.reject{|k,v| k == 'he'}.values.sum
    @copyright_facet = es_buckets_to_facet(@collection.aggs['copyright_status']['buckets'], {'false' => 0,'true' => 1})
    author_ids = @collection.aggs['author_ids']['buckets'].map{|x| x['key']}

    # Used to populate authors multiselect modal on works browse page
    @authors_list = (es_query == {match_all: {}} && filter.blank?) ? Person.all : Person.where(id: author_ids)
    @authors_list = @authors_list.select(:id, :name).sort_by(&:name)

    if @sort[0..11] == 'alphabetical' # subset of @sort to ignore direction
      unless params[:page].blank?
        params[:to_letter] = nil # if page was specified, forget the to_letter directive
      end
      oldpage = @page
      @works = @collection.page(@page) # get page X of manifestations
      @total_pages = @works.total_pages

      unless params[:to_letter].blank?
        adjust_page_by_letter(@collection, params[:to_letter], :sort_title, @sort_dir, true)
        @works = @collection.page(@page) if oldpage != @page # re-get page X of manifestations if adjustment was made
      end

      # one idea is to search with the same filters AND a title match for each letter plus * (wildcard), COUNT the results, and calculate the page numbers by division with page size
      @ab = []
      ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר', 'ש', 'ת'].each{|l|
        @ab << [l, '']
      }
      # @ab = prep_ab(@collection, @works, :sort_title)
    else
      @works = @collection.page(@page)
      @total_pages = @works.total_pages
    end
  end

  def prep_for_browse
    @page = params[:page] || 1
    @page = 1 if ['0',''].include?(@page) # slider sets page to zero, awkwardly
    es_prep_collection

    @total = @collection.count
    d = Date.today
    @maxdate = "#{d.year}-#{'%02d' % d.month}"
    #@maxdate = d.year.to_s
    #@maxdate = Date.today
    @header_partial = 'manifestation/browse_top'
  end

  def prep_ab(whole, subset, fieldname)
    ret = []
    abc_present = whole.pluck(fieldname).map{|t| t.nil? || t.empty? ? '' : t[0] }.uniq.sort
    dummy = subset[0] # bizarrely, unless we force this query, the pluck below returns *a wrong set* (off by one page or so)
    abc_active = subset.pluck(fieldname).map{|t| t.nil? || t.empty? ? '' : t[0] }.uniq.sort
    ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר', 'ש', 'ת'].each{|l|
      status = ''
      unless abc_present.include?(l)
        if(abc_active.empty? || l >= abc_active.last)
          status = :disabled
        else
          status = :in_range_disabled
        end
      end
      status = :active if abc_active.include?(l)
      ret << [l, status]
    }
    return ret
  end

  def refuse_unreasonable_page
    return true if params[:page].nil? || params[:page].empty?
    p = params[:page].to_i
    if p.nil? || p > 2000
      head(403)
    else
      return true
    end
  end

  def prep_for_print
    @m = Manifestation.find(params[:id])
    if @m.nil?
      head :ok
    else
      unless @m.published?
        flash[:notice] = t(:work_not_available)
        redirect_to '/'
      else
        @e = @m.expressions[0]
        @w = @e.works[0]
        @author = @w.persons[0] # TODO: handle multiple authors
        unless is_spider?
          impressionist(@m)
          unless @author.nil?
            impressionist(@author) # also increment the author's popularity counter
          end
        end
        if @author.nil?
          @author = Person.new(name: '?')
        end
        @translators = @m.translators
        @illustrators = @w.illustrators
        @editors = @e.editors
        @page_title = "#{@m.title_and_authors} - #{t(:default_page_title)}"
        if @print
          @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
        end
      end
    end
  end

  def prep_for_read
    @print = false
    prep_for_print
    unless @m.nil?
      lines = @m.markdown.lines
      tmphash = {}
      @chapters = [] # TODO: add sub-chapters, indenting two nbsps in dropdown

      ## div-wrapping chapters, trying to debug the scrollspy...
      #first = true
      #@m.heading_lines.reverse.each{ |linenum|
      #  insert_text = "<div id=\"ch#{linenum}\" role=\"tabpanel\"> <a name=\"ch#{linenum}\"></a>\r\n"
      #  unless first
      #    insert_text = "</div>" + insert_text
      #  else
      #    first = false
      #  end
      #  lines.insert(linenum, insert_text)
      #  # lines.insert(linenum, "\n<p id=\"ch#{linenum}\"></p>\r\n")
      #  tmphash[sanitize_heading(lines[linenum+1][2..-1].strip)] = linenum.to_s
      #} # annotate headings in reverse order, to avoid offsetting the next heading
      #lines << "</div>\n" unless first # close final section if any headings existed in the text
      ch_count = 0
      @m.heading_lines.reverse.each{ |linenum|
        ch_count += 1
        insert_text = "<a name=\"ch#{linenum}\" class=\"ch_anch\" id=\"ch#{linenum}\">&nbsp;</a>\r\n"
        lines.insert(linenum, insert_text)
        tmphash[ch_count.to_s.rjust(4, "0")+sanitize_heading(lines[linenum+1][2..-1].strip)] = linenum.to_s
      } # annotate headings in reverse order, to avoid offsetting the next heading
      tmphash.keys.reverse.map{|k| @chapters << [k[4..-1], tmphash[k]]}
      @selected_chapter = tmphash.keys.last
      @html = MultiMarkdown.new(lines.join('')).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'').gsub('<table>','<div style="overflow-x:auto;"><table>').gsub('</table>','</table></div>') # remove MMD's automatic figcaptions and make tables scroll to avoid breaking narrow mobile devices
      @tabclass = set_tab('works')
      @entity = @m
      @pagetype = :manifestation
      @print_url = url_for(action: :print, id: @m.id)
      @liked = (current_user.nil? ? false : @m.likers.include?(current_user))
      if @e.translation?
        if @e.works[0].expressions.count > 1 # one is the one we're looking at...
          @additional_translations = []
          @e.works[0].expressions.joins(:manifestations).includes(:manifestations).each do |ex|
            @additional_translations << ex unless ex == @e
          end
        end
      end
    end
  end
end
