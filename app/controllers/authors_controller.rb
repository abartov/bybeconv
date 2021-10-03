require 'diffy'
include BybeUtils

class AuthorsController < ApplicationController
  before_action only: [:new, :create, :show, :edit, :list, :delete_photo, :edit_toc, :update] do |c| c.require_editor('edit_people') end

  def get_random_author
    @author = nil
    unless params[:genre].nil? || params[:genre].empty?
      @author = Person.where(id: Person.in_genre(params[:genre]).pluck(:id).sample(1))[0]
    else
      has_something = false
      i = 0
      while i < 5 && has_something == false
        @author = Person.where(id: Person.has_toc.pluck(:id).sample(1))[0]
        i += 1
        has_something = true if @author.manifestations.published.count > 0
      end
    end
    render partial: 'shared/surprise_author', locals: {author: @author, initial: false, id_frag: params[:id_frag], passed_genre: params[:genre], passed_mode: params[:mode], side: params[:side]}
  end

  def delete_photo
    @author = Person.find(params[:id])
    if @author.profile_image.file?
      @author.profile_image.destroy
      @author.save!
      flash[:notice] = t(:deleted_successfully)
    end
    show
    render action: :show
  end
  def whatsnew_popup
    @author = Person.find(params[:id])
    pubs = @author.works_since(1.month.ago, 1000)
    @pubscoll = {}
    pubs.each {|m|
      e = m.expressions[0]
      @pubscoll[e.genre] = [] if @pubscoll[e.genre].nil?
      @pubscoll[e.genre] << m
    }
    @pubs = textify_new_pubs(@pubscoll)
    render partial: 'whatsnew_popup'
  end
  def latest_popup
    @author = Person.find(params[:id])
    pubs = @author.cached_latest_stuff
    @pubscoll = {}
    pubs.each {|m|
      e = m.expressions[0]
      @pubscoll[e.genre] = [] if @pubscoll[e.genre].nil?
      @pubscoll[e.genre] << m
    }
    @pubs = textify_new_pubs(@pubscoll)
    render partial: 'whatsnew_popup'
  end
  def es_datefield_name_from_datetype(dt)
    case dt
    when 'uploaded'
      return 'pby_publication_date'
    when 'birth'
      return 'birth_year'
    when 'death'
      return 'death_year'
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
      ret << {terms: {public_domain: cright}}
      @filters += @copyright.map{|x| [helpers.textify_copyright_status(x == 1), "copyright_#{x}", :checkbox]}
    end
    # languages
    if params['ckb_languages'].present?
      if params['ckb_languages'] == ['xlat']
        ret << {must_not: {term: {orig_lang: 'he'}}}
        @filters << [I18n.t(:translations), 'lang_xlat', :checkbox]
      else
        @languages = params['ckb_languages'].reject{|x| x == 'xlat'}
        if @languages.present?
          ret << {terms: {orig_lang: @languages}}
          @filters += @languages.map{|x| ["#{I18n.t(:orig_lang)}: #{helpers.textify_lang(x)}", "lang_#{x}", :checkbox]}
        end
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
    datefield = es_datefield_name_from_datetype(@datetype)
    ret << {range: {"#{datefield}" => range_expr }} unless range_expr.empty?
    #     { "range": { "publish_date": { "gte": "2015-01-01" }}}
    return ret
  end
  def build_es_query_from_filters
    ret = {}
    if params['search_input'].present?
      ret['match'] = {author_string: params['search_input']}
      @filters << [I18n.t(:author_x, {x: params['search_input']}), :authors, :text]
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
        ord = {sort_name: (@sort_dir == :default ? :asc : @sort_dir)}
      when 'popularity'
        ord = {impressions_count: (@sort_dir == :default ? :desc : @sort_dir)}
      when 'publication_date'
        ord = "expressions.date #{@sort_dir == :default ? 'asc' : @sort_dir}"
      when 'creation_date'
        ord = "works.date #{@sort_dir == :default ? 'asc' : @sort_dir}"
      when 'upload_date'
        ord = {created_at: (@sort_dir == :default ? :desc : @sort_dir)}
      end
    else
      sdir = (@sort_dir == :default ? :asc : @sort_dir)
      @sort = "alphabetical_#{sdir}"
      ord = {sort_name: sdir}
    end
    standard_aggregations = {
      periods: {terms: {field: 'period'}},
      genres: {terms: {field: 'genre'}},
      languages: {terms: {field: 'orig_lang', size: get_langs.count + 1}},
      copyright_status: {terms: {field: 'copyright_status'}},
      genders: {terms: {field: 'gender'}},
    }
    filter = build_es_filter_from_filters
    es_query = build_es_query_from_filters
    es_query = {match_all: {}} if es_query == {}
    @collection = PeopleIndex.query(es_query).filter(filter).aggregations(standard_aggregations).order(ord).limit(100) # prepare ES query
    @emit_filters = true if params[:load_filters] == 'true' || params[:emit_filters] == 'true'
    @total = @collection.count # actual query triggered here
    @gender_facet = es_buckets_to_facet(@collection.aggs['genders']['buckets'], Person.genders)
    @period_facet = es_buckets_to_facet(@collection.aggs['periods']['buckets'], Expression.periods)
    @genre_facet = es_buckets_to_facet(@collection.aggs['genres']['buckets'], get_genres.to_h {|g| [g,g]})
    @language_facet = es_buckets_to_facet(@collection.aggs['languages']['buckets'], get_langs.to_h {|l| [l,l]})
    @language_facet[:xlat] = @language_facet.reject{|k,v| k == 'he'}.values.sum
    @copyright_facet = es_buckets_to_facet(@collection.aggs['copyright_status']['buckets'], {'false' => 0,'true' => 1})
    if @sort[0..11] == 'alphabetical' # subset of @sort to ignore direction
      unless params[:page].blank?
        params[:to_letter] = nil # if page was specified, forget the to_letter directive
      end
      oldpage = @page
      @authors = @collection.page(@page) # get page X of manifestations
      @total_pages = @authors.total_pages

      unless params[:to_letter].blank?
        adjust_page_by_letter(@collection, params[:to_letter], :sort_name, @sort_dir, true)
        @authors = @collection.page(@page) if oldpage != @page # re-get page X of manifestations if adjustment was made
      end

      # one idea is to search with the same filters AND a title match for each letter plus * (wildcard), COUNT the results, and calculate the page numbers by division with page size
      @ab = []
      ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר', 'ש', 'ת'].each{|l|
        @ab << [l, '']
      }
      # @ab = prep_ab(@collection, @works, :sort_title)
    else
      @authors = @collection.page(@page)
      @total_pages = @authors.total_pages
    end
  end

  def browse
    @page_title = t(:authors_list)+' – '+t(:project_ben_yehuda)
    @pagetype = :authors
    @page = params[:page] || 1
    @page = 1 if ['0',''].include?(@page) # slider sets page to zero, awkwardly
    es_prep_collection
    @total = @collection.count
    d = Date.today
    @maxdate = "#{d.year}-#{'%02d' % d.month}"
    @header_partial = 'authors/browse_top'
  end
  def all
    @page_title = t(:all_authors)+' '+t(:project_ben_yehuda)
    @pagetype = :authors
    @authors_abc = Person.order(:sort_name).page(params[:page]) # get page X of all authors
  end

  def create_toc
    author = Person.find(params[:id])
    unless author.nil?
      if author.toc.nil?
        toc = Toc.new(toc: AppConstants.toc_template, status: :raw, credit_section: '')
        toc.save!
        author.toc = toc
        author.save!
        flash[:notice] = t(:created_toc)
        redirect_to controller: :authors, action: :show, id: params[:id]
      else
        flash[:error] = t(:already_has_toc)
        redirect_to controller: :authors, action: :show, id: params[:id]
      end
    else
      flash[:error] = t(:no_such_item)
      redirect_to controller: :admin, action: :index
    end
  end

  def index
    @page_title = t(:authors)+' - '+t(:project_ben_yehuda)
    @pop_by_genre = cached_popular_authors_by_genre # get popular authors by genre + most popular translated
    @rand_by_genre = {}
    @pagetype = :authors
    @surprise_by_genre = {}
    get_genres.each do |g|
      @rand_by_genre[g] = randomize_authors(@pop_by_genre[g][:orig], g) # get random authors by genre
      @rand_by_genre[g] = @pop_by_genre[g][:orig] if @rand_by_genre[g].empty? # workaround for genres with very few authors (like fables, in 2017)
      @surprise_by_genre[g] = @rand_by_genre[g].pop # make one of the random authors the surprise author
    end
    @authors_abc = Person.order(:sort_name).limit(100) # get page 1 of all authors
    @author_stats = {total: Person.cached_toc_count, pd: Person.cached_pd_count, translators: Person.cached_translators_count, translated: Person.cached_no_toc_count}
    @author_stats[:permission] = @author_stats[:total] - @author_stats[:pd]
    @authors_by_genre = count_authors_by_genre
    @new_authors = Person.has_toc.latest(3)
    @featured_author = featured_author
    (@fa_snippet, @fa_rest) = @featured_author.nil? ? ['',''] : snippet(@featured_author.body, 500)
    @rand_translated_authors = Person.translatees.order('RAND()').limit(5)
    @rand_translators = Person.translators.order('RAND()').limit(5)
    @pop_translated_authors = Person.get_popular_xlat_authors.limit(5)
    @pop_translators = Person.get_popular_translators.limit(5)
  end

  def new
    @person = Person.new
    @page_title = t(:new_author)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  def create
    params[:person][:wikidata_id] = params[:person][:wikidata_id].strip[1..-1] if params[:person] and params[:person][:wikidata_id] and params[:person][:wikidata_id][0] and params[:person][:wikidata_id].strip[0] == 'Q' # tolerate pasting the Wikidata number with the Q
    Chewy.strategy(:atomic) {
      @person = Person.new(person_params)

      respond_to do |format|
        if @person.save
          format.html { redirect_to url_for(action: :show, id: @person.id), notice: t(:updated_successfully) }
          format.json { render json: @person, status: :created, location: @person }
        else
          format.html { render action: "new" }
          format.json { render json: @person.errors, status: :unprocessable_entity }
        end
      end
    }
  end

  def destroy
    @author = Person.find(params[:id])
    Chewy.strategy(:atomic) {
      if @author.nil?
        flash[:error] = t(:no_such_item)
        redirect_to '/'
      else
        @author.destroy!
        redirect_to action: :list
      end
    }
  end

  def show
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      # TODO: add other types of content
      @page_title = t(:author_details)+': '+@author.name
    end
  end

  def edit
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @page_title = t(:edit)+': '+@author.name
      # do stuff
    end
  end

  def update
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      params[:person][:wikidata_id] = params[:person][:wikidata_id].strip[1..-1] if params[:person] and params[:person][:wikidata_id] and params[:person][:wikidata_id][0] and params[:person][:wikidata_id].strip[0] == 'Q' # tolerate pasting the Wikidata number with the Q
      old_period = @author.period
      Chewy.strategy(:atomic) {
        if @author.update_attributes(person_params)
          @author.update_expressions_period if @author.period != old_period # if period was updated, update the period of this person's Expressions
          flash[:notice] = I18n.t(:updated_successfully)
          redirect_to action: :show, id: @author.id
        else
          format.html { render action: 'edit' }
          format.json { render json: @author.errors, status: :unprocessable_entity }
        end
      }
    end
  end

  def list
    @page_title = t(:authors)+' - '+t(:project_ben_yehuda)
    def_order = 'tocs.status asc, metadata_approved asc, sort_name asc'
    if params[:q].nil? or params[:q].empty?
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").page(params[:page]).order(params[:order].nil? ? def_order : params[:order]) # TODO: pagination
    else
      @q = params[:q]
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").where('name like ? or other_designation like ?', "%#{params[:q]}%", "%#{params[:q]}%").page(params[:page]).order(params[:order].nil? ? def_order : params[:order])
    end
  end

  def toc
    @author = Person.find(params[:id])
    unless @author.nil?
      @tabclass = set_tab('authors')
      @print_url = url_for(action: :print, id: @author.id)
      @pagetype = :author
      @header_partial = 'authors/author_top'
      @entity = @author
      @page_title = "#{@author.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"
      impressionist(@author) unless is_spider? # log actions for pageview stats
      @og_image = @author.profile_image.url(:thumb)
      @latest = textify_titles(@author.cached_latest_stuff, @author)
      @featured = @author.featured_work
      @aboutnesses = @author.aboutnesses
      @any_curated = @featured.present? || @aboutnesses.count > 0
      unless @featured.empty?
        (@fc_snippet, @fc_rest) = snippet(@featured[0].body, 500) # prepare snippet for collapsible
      end
      unless @author.toc.nil?
        prep_toc
      else
        generate_toc
      end
      prep_user_content(:author)
      @scrollspy_target = 'genrenav'
    else
      flash[:error] = I18n.t(:no_toc_yet)
      redirect_to '/'
    end
  end

  def print
    @author = Person.find(params[:id])
    @print = true
    prep_for_print
    @footer_url = url_for(action: :toc, id: @author.id)
  end

  def edit_toc
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = I18n.t('no_such_item')
      redirect_to '/'
    elsif @author.toc.nil?
      flash[:error] = I18n.t('no_toc_yet')
      redirect_to '/'
    else
      @page_title = t(:edit_toc)+': '+@author.name
      unless params[:markdown].nil? # handle update payload
        if params[:old_timestamp].to_datetime != @author.toc.updated_at.to_datetime # check for update since form was issued
          # reject update, provide diff and fresh editbox
          @diff = Diffy::Diff.new(params[:markdown], @author.toc.toc)
          @rejected_update = params[:markdown]
        else
          t = @author.toc
          t.toc = params[:markdown]
          t.credit_section = params[:credits]
          t.status = Toc.statuses[params[:toc_status]]
          t.save!
        end
      end
      prep_toc
    end
  end

  protected

  def generate_toc
    @works = @author.cached_original_works_by_genre
    @translations = @author.cached_translations_by_genre
    @genres_present = []
    @works.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
    @translations.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
  end
  def person_params
    params[:person].permit(:affiliation, :comment, :country, :name, :nli_id, :other_designation, :viaf_id, :public_domain, :profile_image, :birthdate, :deathdate, :wikidata_id, :wikipedia_url, :wikipedia_snippet, :blog_category_url, :profile_image, :metadata_approved, :gender, :bib_done, :period, :sort_name)
  end
  def prep_for_print
    @author = Person.find(params[:id])
    if @author.nil?
      head :ok
    else
      impressionist(@author) unless is_spider?
      @page_title = "#{@author.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"
      unless @author.toc.nil?
        prep_toc
      else
        generate_toc
      end
    end
  end

end
