class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_paper_trail_whodunnit
  before_filter :set_font_size
  after_filter :set_access_control_headers

  # class variables
  @@whatsnew_cache = nil
  @@countauthors_cache = nil
  @@genre_popups_cache = nil
  @@pop_authors_by_genre = nil

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
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  def search_results
    render 'shared/search_results', layout: false
  end

  private

  def require_editor
    return true if current_user && current_user.editor?
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
      fcfs = FeaturedContentFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).order('RAND()').limit(1)
      if fcfs.count == 1
        fcfs[0].featured_content
      else
        nil
      end
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
      vpfs = VolunteerProfileFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).order('RAND()').limit(1)
      if vpfs.count == 1
        vpfs[0].volunteer_profile
      else
        nil
      end
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
    return Manifestation.order('RAND()').limit(how_many)
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

  def whatsnew_anonymous
    if @@whatsnew_cache.nil?
      authors = {}
      Manifestation.new_since(1.month.ago).each {|m|
        e = m.expressions[0]
        person = e.persons[0] # TODO: more nuance
        next if person.nil? # shouldn't happen, but might in a dev. env.
        authors[person] = {} if authors[person].nil?
        authors[person][e.genre] = [] if authors[person][e.genre].nil?
        authors[person][e.genre] << m
      }
      @@whatsnew_cache = authors
    end
    return @@whatsnew_cache
  end

  def sanitize_heading(h)
    return h.gsub(/\[\^ftn\d+\]/,'').gsub(/^#+/,'&nbsp;&nbsp;&nbsp;').strip
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
