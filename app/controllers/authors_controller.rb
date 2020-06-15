require 'diffy'
include BybeUtils

class AuthorsController < ApplicationController
  before_action only: [:new, :create, :show, :edit, :list, :edit_toc, :update] do |c| c.require_editor('edit_people') end

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

  def whatsnew_popup
    @author = Person.find(params[:id])
    @pubs = @author.works_since(1.month.ago, 1000)
    render partial: 'whatsnew_popup'
  end

  def all
    @page_title = t(:all_authors)+' '+t(:project_ben_yehuda)
    @pagetype = :authors
    @authors_abc = Person.order(:name).page(params[:page]) # get page X of all authors
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
    @authors_abc = Person.order(:name).limit(100) # get page 1 of all authors
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
    def_order = 'tocs.status asc, metadata_approved asc, name asc'
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
    params[:person].permit(:affiliation, :comment, :country, :name, :nli_id, :other_designation, :viaf_id, :public_domain, :profile_image, :birthdate, :deathdate, :wikidata_id, :wikipedia_url, :wikipedia_snippet, :blog_category_url, :profile_image, :metadata_approved, :gender, :bib_done, :period)
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
