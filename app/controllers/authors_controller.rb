require 'diffy'
include BybeUtils

class AuthorsController < ApplicationController
  before_filter :require_editor, only: [:new, :create, :show, :edit, :list, :edit_toc, :update]

  def get_random_author
    @author = nil
    unless params[:genre].nil? || params[:genre].empty?
      @author = Person.in_genre(params[:genre]).order('RAND()').limit(1)[0]
    else
      @author = Person.has_toc.order('RAND()').limit(1)[0]
    end
    render partial: 'shared/surprise_author', locals: {author: @author, initial: false, id_frag: params[:id_frag], passed_genre: params[:genre], passed_mode: params[:mode], side: params[:side]}
  end

  def all
    @page_title = t(:all_authors)+' '+t(:project_ben_yehuda)
    @pagetype = :authors
    @authors_abc = Person.order(:name).page(params[:page]).limit(25) # get page X of all authors
  end

  def create_toc
    author = Person.find(params[:id])
    unless author.nil?
      if author.toc.nil?
        toc = Toc.new(toc: AppConstants.toc_template, status: :raw, credits: '')
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
    @authors_abc = Person.order(:name).limit(25) # get page 1 of all authors
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
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to url_for(action: :show, id: @person.id), notice: t(:updated_successfully) }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @author.destroy!
      redirect_to action: :list
    end
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
      if @author.update_attributes(params[:person])
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
    def_order = 'tocs.status asc, metadata_approved asc, name asc'
    if params[:q].nil? or params[:q].empty?
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").page(params[:page]).order(params[:order].nil? ? def_order : params[:order]) # TODO: pagination
    else
      @q = params[:q]
      @people = Person.joins("LEFT JOIN tocs on people.toc_id = tocs.id ").where('name like ?', "%#{params[:q]}%").page(params[:page]).order(params[:order].nil? ? def_order : params[:order])
    end
  end

  def toc
    @author = Person.find(params[:id])
    unless @author.nil?
      @tabclass = set_tab('authors')
      @print_url = url_for(action: :print, id: @author.id)
      @pagetype = :author
      @entity = @author
      @page_title = "#{@author.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"
      # temporary protection against null ToCs while we're migrating
      impressionist(@author) unless is_spider? # log actions for pageview stats
      unless @author.toc.nil?
        prep_toc
      else
        generate_toc
      end
    else
      flash[:error] = I18n.t(:no_toc_yet)
      redirect_to '/'
    end
  end

  def print
    @author = Person.find(params[:id])
    # TODO: implement
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
      @credit_section = @author.toc.credit_section.nil? ? "": @author.toc.credit_section
      @toc_timestamp = @author.toc.updated_at
      @works = @author.all_works_title_sorted
    end
  end

  protected

  def prep_toc
    old_toc = @author.toc.toc
    @toc = @author.toc.refresh_links
    if @toc != old_toc # update the TOC if there have been HtmlFiles published since last time, regardless of whether or not further editing would be saved.
      @author.toc.toc = @toc
      @author.toc.save!
    end
    markdown_toc = toc_links_to_markdown_links(@toc)
    toc_parts = divide_by_genre(markdown_toc)
    @genres_present = toc_parts.shift # first element is the genres array
    @htmls = toc_parts.map{|genre, tocpart| [genre, MultiMarkdown.new(tocpart).to_html.force_encoding('UTF-8')]}
    credits = @author.toc.credit_section || ''
    @credits = MultiMarkdown.new(credits).to_html.force_encoding('UTF-8').gsub('<li', '<li class="col-sm-6"').gsub('<ul','<ul class="list-unstyled row"')
  end

  def generate_toc
    @works = @author.cached_original_works_by_genre
    @translations = @author.cached_translations_by_genre
    @genres_present = []
    @works.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
    @translations.each_key {|k| @genres_present << k unless @works[k].size == 0 || @genres_present.include?(k)}
  end
end
