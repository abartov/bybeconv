class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :set_paper_trail_whodunnit
  before_action :set_font_size
  after_action :set_access_control_headers

  # class variables
  @@countauthors_cache = nil
  @@genre_popups_cache = nil
  @@pop_authors_by_genre = nil
  SPIDERS = ['msnbot', 'yahoo! slurp','googlebot','bingbot','duckduckbot','baiduspider','yandexbot']

  def set_font_size
    if current_user
      key = "u_#{current_user.id}_fontsize"
      @fontsize = Rails.cache.fetch(key)
      if @fontsize.nil?
        Rails.cache.fetch(key) do
          current_user.preferences.fontsize
        end
        @fontsize = current_user.preferences.fontsize
      end
    else
      @fontsize = '2'
    end
  end

  def set_access_control_headers
#    headers['Access-Control-Allow-Origin'] = 'http://benyehuda.org/'
    headers['Access-Control-Allow-Origin'] = '*' # TODO: restrict
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  def search_results
    render 'shared/search_results', layout: false
  end

  protected

  def require_editor(bits = nil)
    editor = current_user && current_user.editor?
    if editor
      return true if bits.nil?
      # else check for specific bits
      li = ListItem.where(listkey: bits, item: current_user).first
      return true unless li.nil?
    end
    redirect_to '/', flash: { error: 'Not an editor' }
  end

  def require_admin
    return true if current_user && current_user.admin?
    redirect_to '/', flash: { error: 'Not an admin' }
  end

  def require_user
    return true if current_user
    redirect_to session_login_path, flash: {
      error: 'You must be logged in to access this page' }
  end

  def popular_works(update = false)
    Manifestation.recalc_popular if update
    @popular_works = Manifestation.get_popular_works
  end

  def cached_popular_tags
    Rails.cache.fetch("popular_tags", expires_in: 24.hours) do # memoize
      Tagging.group(:tag).order('count_tag_id DESC').count('tag_id')
    end
  end

  def featured_content
    Rails.cache.fetch("featured_content", expires_in: 1.hours) do # memoize
      ret = nil
      fcfs = FeaturedContentFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).order('RAND()').limit(1)
      if fcfs.count == 1
        ret = fcfs[0].featured_content
      end
      ret
    end
  end

  def featured_author
    Rails.cache.fetch("featured_author", expires_in: 1.hours) do # memoize
      fas = FeaturedAuthorFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).order('RAND()').limit(1)
      if fas.count == 1
        fas[0].featured_author
      else
        nil
      end
    end
  end

  def featured_volunteer
    Rails.cache.fetch("featured_volunteer", expires_in: 10.hours) do # memoize
      ret = nil
      vpfs = VolunteerProfileFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).order('RAND()').limit(1)
      if vpfs.count == 1
        ret = vpfs[0].volunteer_profile
      end
      ret
    end
  end

  def popular_authors(update = false)
    Person.recalc_popular if update
    @popular_authors = Person.get_popular_authors
  end

  def randomize_authors(exclude_list, genre = nil)
    list = []
    ceiling = [Person.cached_toc_count - exclude_list.count - 1, 10].min
    return list if ceiling <= 0
    i = 0
    begin
      if genre.nil?
        candidates = Person.has_toc.order('RAND()').limit(ceiling-list.size) # fetch as many as are still needed
      else
        candidates = Person.has_toc.joins(:expressions).where(expressions: { genre: genre}).order('RAND()').limit(ceiling-list.size) # fetch as many as are still needed
      end

      candidates.each { |author| list << author unless (exclude_list.include? author) or (list.include? author) }
      i += 1
    end until list.size >= ceiling or i > 10 # TODO: fix bug where only one author is retrieved by above block
    return list
  end

  def randomize_works(how_many)
    return Manifestation.where(id: Manifestation.pluck(:id).sample(how_many), status: Manifestation.statuses[:published]) # NOTE: because of the status check, less than how_many may be returned. This is a necessary sacrifice for now because ORDER RAND() is way too slow!
    # TODO: maybe fix by sampling twice the requested amount and then returning only up to how_many?  On the assumption very few manifestations are not 'published', this would work.
    #return Manifestation.order('RAND()').limit(how_many)
  end

  def cached_popular_authors_by_genre
    if @@pop_authors_by_genre.nil?
      ret = {}
      get_genres.each {|g|
        ret[g] = {}
        ret[g][:orig] = Person.get_popular_authors_by_genre(g)
        ret[g][:xlat] = Person.get_popular_xlat_authors_by_genre(g)
      }
      @@pop_authors_by_genre = ret
    end
    return @@pop_authors_by_genre
  end

  def popups_by_genre
    if @@genre_popups_cache.nil?
      ret = {}
      get_genres.each {|g|
        ret[g] = {}
        ret[g][:authors] = Person.get_popular_authors_by_genre(g)
        ret[g][:heb_works] = Manifestation.popular_works_by_genre(g, false)
        ret[g][:xlat_works] = Manifestation.popular_works_by_genre(g, true)
      }
      @@genre_popups_cache = ret
    end
    return @@genre_popups_cache
  end

  def count_authors_by_genre
    if @@countauthors_cache.nil?
      ret = {}
      get_genres.each {|g|
        ret[g] = Person.has_toc.joins(:expressions).where(expressions: {genre: g}).distinct.count
      }
      @@countauthors_cache = ret
    end
    return @@countauthors_cache
  end
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
    @credit_section = @author.toc.credit_section.nil? ? "": @author.toc.credit_section
    @toc_timestamp = @author.toc.updated_at
    @works = @author.all_works_title_sorted
    @fresh_works = @author.works_since(2.days.ago, 1000)
    unless @fresh_works.empty?
      @fresh_works_markdown = @fresh_works.map{|m| "\\n&&& פריט: מ#{m.id} &&& כותרת: #{m.title}#{m.expressions[0].translation ? ' / '+m.authors_string : ''} &&&\\n"}.join('').html_safe
    end
end

  def is_spider?
    ua = request.user_agent.downcase
    return (SPIDERS.detect{|s| ua.include?(s)} ? true : false)
  end

  def whatsnew_anonymous
    Rails.cache.fetch("whatsnew_anonymous", expires_in: 2.hours) do # memoize
      logger.info("cache failure: calculating whatsnew anonymous")
      return whatsnew_since(1.month.ago)
    end
  end

  def whatsnew_since(timestamp)
    authors = {}
    Manifestation.all_published.new_since(timestamp).each {|m|
      e = m.expressions[0]
      person = e.persons[0] # TODO: more nuance
      next if person.nil? # shouldn't happen, but might in a dev. env.
      authors[person] = {} if authors[person].nil?
      authors[person][e.genre] = [] if authors[person][e.genre].nil?
      authors[person][e.genre] << m
    }
    authors
  end

  def sanitize_heading(h)
    return h.gsub(/\[\^ftn\d+\]/,'').gsub(/^#+/,'&nbsp;&nbsp;&nbsp;').gsub(/\[\^\d+\]/,'').gsub('\"','"').strip
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def html_entities_coder
    @html_entities_coder ||= HTMLEntities.new
  end

  def set_tab(tab)
    tabs = ['contact','help','faq','authors','works','periods']
    ret = {}
    tabs.each {|t| ret[t] = tab == t ? 'active' : ''}
    return ret
  end

  def get_intro(markdown)
    lines = markdown[0..2000].lines[1..-2]
    if lines.empty?
      lines = markdown[0..[5000,markdown.length].min].lines[0..-2]
    end
    lines.join + '...'
  end

  helper_method :current_user, :html_entities_coder, :get_intro
end
