require 'diffy'
include BybeUtils
include ApplicationHelper

class AuthorsController < ApplicationController
  include FilteringAndPaginationConcern

  before_action only: [:new, :publish, :create, :show, :edit, :list, :add_link, :delete_link, :delete_photo, :edit_toc, :update, :to_manual_toc] do |c| c.require_editor('edit_people') end
  autocomplete :tag, :name, :limit => 2

  def publish
    @author = Person.find(params[:id])
    if @author
      if params[:commit].present?
        # POST request
        if @author.unpublished? and (@author.all_works_including_unpublished.count > 0)
          @author.publish!
          Rails.cache.delete('newest_authors') # force cache refresh
          Rails.cache.delete('homepage_authors')
          Rails.cache.delete("au_#{@author.id}_work_count")
          flash[:success] = t(:published)
        else
          @author.awaiting_first!
          flash[:success] = t(:awaiting_first)
        end
        redirect_to action: :list
      else
        # GET request
        @manifestations = @author.all_works_including_unpublished
      end
    else
      flash[:error] = t(:not_found)
      redirect_to admin_index_path
    end
  end

  def get_random_author
    genre = params[:genre]
    render partial: 'shared/surprise_author',
           locals: {
             author: RandomAuthor.call(genre),
             initial: false,
             id_frag: params[:id_frag],
             passed_genre: genre,
             passed_mode: params[:mode],
             side: params[:side]
           }
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
      genre = m.expression.work.genre
      @pubscoll[genre] = [] if @pubscoll[genre].nil?
      @pubscoll[genre] << m
    }
    @pubs = textify_new_pubs(@pubscoll)
    render partial: 'whatsnew_popup'
  end

  def latest_popup
    @author = Person.find(params[:id])
    pubs = @author.cached_latest_stuff
    @pubscoll = {}
    pubs.each {|m|
      genre = m.expression.work.genre
      @pubscoll[genre] = [] if @pubscoll[genre].nil?
      @pubscoll[genre] << m
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
      ret << {terms: {gender: @genders}}
      @filters += @genders.map{|x| [I18n.t(:author)+': '+I18n.t(x), "gender_#{x}", :checkbox]}
    end
    # genres
    @genres = params['ckb_genres'] if params['ckb_genres'].present?
    if @genres.present?
      ret << {terms: {genre: @genres}}
      @filters += @genres.map{|x| [helpers.textify_genre(x), "genre_#{x}", :checkbox]}
    end
    # copyright
    @intellectual_property_types = params['ckb_intellectual_property']
    if @intellectual_property_types.present?
      ret << { terms: { intellectual_property: @intellectual_property_types } }
      @filters += @intellectual_property_types.map do |ip|
        [helpers.textify_intellectual_property(ip), "intellectual_property_#{ip}", :checkbox]
      end
    end
    # languages
    if params['ckb_languages'].present?
      @languages = params['ckb_languages'].reject { |x| x == 'xlat' }
      if @languages.present?
        ret << { terms: { language: @languages } }
        @filters += @languages.map { |x| ["#{I18n.t(:orig_lang)}: #{helpers.textify_lang(x)}", "lang_#{x}", :checkbox] }
      end
    end
    # tags by tag_id
    @tag_ids = params['tag_ids'].split(',').map(&:to_i) unless @tag_ids.present? || params['tag_ids'].blank?
    if @tag_ids.present?
      tag_data = Tag.where(id: @tag_ids).pluck(:id, :name)
      ret << {terms: {tags: tag_data.map(&:last)}}
      @filters += tag_data.map { |x| [x.last, "tag_#{x.first}", :checkbox] }
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
      range_expr['lte'] = @todate
      @filters << ["#{I18n.t('d'+@datetype)} #{I18n.t(:todate)}: #{@todate}", :todate, :text]
    end
    datefield = es_datefield_name_from_datetype(@datetype)
    ret << {range: {"#{datefield}" => range_expr }} unless range_expr.empty?

    # Adding filtering by first letter
    @to_letter = params['to_letter']
    if @to_letter.present?
      ret << { prefix: { sort_name: @to_letter } }
      @filters << [I18n.t(:name_starts_with_x, x: @to_letter), :to_letter, :text]
    end

    return ret
  end
  def build_es_query_from_filters
    ret = {}
    if params['search_input'].present?
      ret['match'] = {name: params['search_input']}
      @filters << [I18n.t(:author_x, x: params['search_input']), :search_input, :text]
      @search_input = params['search_input']
    end
    return ret
  end

  def prepare_totals(collection)
    standard_aggregations = {
      periods: { terms: { field: 'period' } },
      genres: { terms: { field: 'genre' } },
      languages: { terms: { field: 'language', size: get_langs.count + 1 } },
      intellectual_property_types: { terms: { field: 'intellectual_property' } },
      genders: { terms: { field: 'gender' } }
    }

    collection = collection.aggregations(standard_aggregations)

    @gender_facet = buckets_to_totals_hash(collection.aggs['genders']['buckets'])
    @period_facet = buckets_to_totals_hash(collection.aggs['periods']['buckets'])
    @genre_facet = buckets_to_totals_hash(collection.aggs['genres']['buckets'])
    @language_facet = buckets_to_totals_hash(collection.aggs['languages']['buckets'])
    @language_facet[:xlat] = @language_facet.except('he').values.sum
    @intellectual_property_facet = buckets_to_totals_hash(collection.aggs['intellectual_property_types']['buckets'])
  end

  SORTING_PROPERTIES = {
    'alphabetical' => { default_dir: 'asc', column: :sort_name },
    'popularity' => { default_dir: 'desc', column: :impressions_count },
    'death_date' => { default_dir: 'asc', column: :death_year },
    'birth_date' => { default_dir: 'asc', column: :birth_year },
    'upload_date' => { default_dir: 'desc', column: :pby_publication_date }
  }.freeze

  def get_sort_column(sort_by)
    SORTING_PROPERTIES[sort_by][:column]
  end

  def es_prep_collection
    @sort_dir = 'default'
    if params[:sort_by].present?
      @sort = params[:sort_by].dup
      @sort_by = params[:sort_by].sub(/_(a|de)sc$/, '')
      @sort_dir = Regexp.last_match(0)[1..] unless Regexp.last_match(0).nil?
    else
      # use alphabetical sorting by default
      @sort = 'alphabetical_asc'
      @sort_by = 'alphabetical'
      @sort_dir = 'asc'
    end

    # This param means that we're getting previous page
    # so we should revert sort ordering while quering ElasticSearch index
    @reverse = params[:reverse] == 'true'
    sort_dir_to_use = if @reverse
                        @sort_dir == 'asc' ? 'desc' : 'asc'
                      else
                        @sort_dir
                      end
    ord = { SORTING_PROPERTIES[@sort_by][:column] => sort_dir_to_use, id: sort_dir_to_use }

    filter = build_es_filter_from_filters
    es_query = build_es_query_from_filters
    es_query = { match_all: {} } if es_query == {}

    @collection = PeopleIndex.query(es_query)
                             .filter(filter)
                             .order(ord)

    @authors = paginate(@collection)
  end

  def browse
    @page_title = "#{t(:authors_list)} – #{t(:project_ben_yehuda)}"
    @pagetype = :authors
    @page = 1 if ['0',''].include?(@page) # slider sets page to zero, awkwardly
    es_prep_collection
    @total = @collection.count
    @maxdate = Time.zone.today.strftime('%Y-%m')
    @header_partial = 'authors/browse_top'
    @authors_list_title = t(:author_list) unless @authors_list_title.present?
    render :browse
    respond_to do |format|
      format.html
      format.js
    end
  end

  def all
    redirect_to '/authors'
  end

  def by_tag
    @page_title = t(:authors_by_tag)+' '+t(:project_ben_yehuda)
    @pagetype = :authors
    tid = params[:id].to_i
    @tag_ids = tid
    tag = Tag.find(tid)
    if tag.present?
      @authors_list_title = t(:authors_by_tag)+': '+tag.name
      browse
    else
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    end
  end

  def create_toc
    author = Person.find(params[:id])
    unless author.nil?
      if author.toc.nil?
        toc = Toc.new(toc: Rails.configuration.constants['toc_template'], status: :raw, credit_section: '')
        toc.save!
        author.toc = toc
        author.save!
        flash[:notice] = t(:created_toc)
      else
        flash[:error] = t(:already_has_toc)
      end
      redirect_to controller: :authors, action: :show, id: params[:id]
    else
      flash[:error] = t(:no_such_item)
      redirect_to controller: :admin, action: :index
    end
  end
  def to_manual_toc
    author = Person.find(params[:id])
    unless author.nil?
      if author.toc.nil?
        @works = author.original_works_by_genre # deliberately NOT using cache here
        @translations = author.translations_by_genre
        @genres_present = []
        @works.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
        @translations.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
        toc = ''
        get_genres.each do |genre|
          if @works[genre].size > 0 || @translations[genre].size > 0
            toc += "## #{textify_genre(genre)}\n"
            if @works[genre].size > 0
              @works[genre].each do |m|
                toc += "&&& פריט: מ#{m.id} &&& כותרת: #{m.title.strip} &&&"
                if m.authors.count > 1
                  au_count = m.authors.count - 1
                  i = 0
                  toc += '('+t(:with)
                  add_authors = ''
                  m.authors.each do |au|
                    next if au == author
                    i += 1
                    add_authors += au.name + (i == au_count ? '' : '; ')
                  end
                  toc += add_authors+')'
                end
                if m.expression.translation
                  toc += " #{t(:translated_by)} "
                  toc += m.expression.translators.map{|p| p.name}.join('; ')
                end
                toc += "\n\n"
              end
            end
            if @translations[genre].size > 0
              toc += "### #{t(:translation)}\n"
              @translations[genre].each do |m|
                toc += "&&& פריט: מ#{m.id} &&& כותרת: #{m.title.strip} &&&"
                toc += t(:by)
                toc += m.expression.work.first_author.name
              end
            end
          end
        end
        newtoc = Toc.new(toc: toc, status: :raw, credit_section: '')
        newtoc.save!
        author.toc = newtoc
        author.save!
        flash[:notice] = t(:created_toc)
      else
        flash[:error] = t(:already_has_toc)
      end
      redirect_to controller: :authors, action: :edit_toc, id: params[:id]
    else
      flash[:error] = t(:no_such_item)
      redirect_to controller: :admin, action: :index
    end
  end

  def new
    @person = Person.new(intellectual_property: :unknown)
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
      if @person.status.blank?
        @person.status = @person.intellectual_property_public_domain? ? :awaiting_first : :unpublished
      end

      if @person.save
        flash.notice = t(:created_successfully)
        redirect_to action: :show, params: { id: @person.id }
      else
        render action: :new, status: :unprocessable_entity
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
    @published_works = @author.original_works.count
    @published_xlats = @author.translations.count
    @total_orig_works = @author.original_work_count_including_unpublished
    @total_xlats = @author.translations_count_including_unpublished
    @aboutnesses = @author.aboutnesses

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

    params[:person][:wikidata_id] = params[:person][:wikidata_id].strip[1..-1] if params[:person] and params[:person][:wikidata_id] and params[:person][:wikidata_id][0] and params[:person][:wikidata_id].strip[0] == 'Q' # tolerate pasting the Wikidata number with the Q
    Chewy.strategy(:atomic) do
      if @author.update(person_params)
        # if period was updated, update the period of this person's Expressions
        if @author.period_previously_changed?
          # In our system period states for Hebrew text period. So for original Hebrew works it should match
          # period of author, and if this is a translation from other language to Hebrew, it should match period of
          # translator. See https://github.com/abartov/bybeconv/issues/149#issuecomment-1141062929
          o = @author.original_works.preload(expression: :work).map(&:expression).
            select { |e| e.work.orig_lang == 'he' }
          t = @author.translations.preload(:expression).map(&:expression).
            select { |e| e.language == 'he' } # we have few translations from Hebrew to other languages
          (o + t).uniq.each { |e| e.update_attribute(:period, @author.period) }
        end
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :show, id: @author.id
      else
        format.html { render action: 'edit' }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @page_title = t(:authors)+' - '+t(:project_ben_yehuda)
    def_order = 'tocs.status asc, sort_name asc'
    if params[:q].nil? or params[:q].empty?
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").page(params[:page]).order(params[:order].nil? ? def_order : params[:order]) # TODO: pagination
    else
      @q = params[:q]
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").where('name like ? or other_designation like ?', "%#{params[:q]}%", "%#{params[:q]}%").page(params[:page]).order(params[:order].nil? ? def_order : params[:order])
    end
  end

  def add_link
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      if(params[:link_description].empty? || params[:add_url].empty?)
        head :bad_request
      else
        @el = ExternalLink.new(linkable: @author, description: params[:link_description], linktype: params[:link_type].to_i, url: params[:add_url], status: :approved)
        @el.save!
      end
    end
  end
  def delete_link
    @el = ExternalLink.find(params[:id])
    if @el.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @el.destroy
      head :ok
    end
  end

  def toc
    @author = Person.find(params[:id])
    unless @author.nil?
      if @author.published?
        @tabclass = set_tab('authors')
        @print_url = url_for(action: :print, id: @author.id)
        @pagetype = :author
        @header_partial = 'authors/author_top'
        @entity = @author
        @page_title = "#{@author.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"
        unless is_spider?
          Chewy.strategy(:bypass) do
            @author.record_timestamps = false # avoid the impression count touching the datestamp
            impressionist(@author)  # log actions for pageview stats
            @author.update_impression
          end
        end

        @og_image = @author.profile_image.url(:thumb)
        @latest = cached_textify_titles(@author.cached_latest_stuff, @author)
        @featured = @author.featured_work
        @aboutnesses = @author.aboutnesses
        @external_links = @author.external_links.status_approved
        @any_curated = @featured.present? || @aboutnesses.count > 0
        unless @featured.empty?
          (@fc_snippet, @fc_rest) = snippet(@featured[0].body, 500) # prepare snippet for collapsible
        end
        @taggings = @author.taggings

        unless @author.toc.nil?
          prep_toc
        else
          generate_toc
        end
        prep_user_content(:author)
        @scrollspy_target = 'genrenav'
      else
        flash[:error] = I18n.t(:author_not_available)
        redirect_to '/'
      end
    else
      flash[:error] = I18n.t(:no_toc_yet)
      redirect_to '/'
    end
  end

  def all_links
    @author = Person.find(params[:id])
    unless @author.nil?
      @external_links = @author.external_links.status_approved
      render partial: 'all_links'
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
      prep_edit_toc

    end
  end

  protected

  def person_params
    params.require(:person).permit(
      :affiliation,
      :comment,
      :country,
      :name,
      :nli_id,
      :other_designation,
      :viaf_id,
      :intellectual_property,
      :profile_image,
      :birthdate,
      :deathdate,
      :wikidata_id,
      :wikipedia_url,
      :wikipedia_snippet,
      :blog_category_url,
      :profile_image,
      :gender,
      :bib_done,
      :period,
      :sort_name,
      :status
    )
  end

  def prep_for_print
    @author = Person.find(params[:id])
    if @author.nil?
      head :ok
    else
      unless is_spider?
        Chewy.strategy(:bypass) do
          @author.record_timestamps = false # avoid the impression count touching the datestamp
          impressionist(@author)
          @author.update_impression
        end
      end      
      @page_title = "#{@author.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"
      unless @author.toc.nil?
        prep_toc
      else
        generate_toc
      end
    end
  end

end
