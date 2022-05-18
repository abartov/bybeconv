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

  # returns BaseUser record associated with current user
  # If user is authenticated it will look for record by user_id, otherwise - by session_id
  # If force_create arg is set to true it will create new BaseUser record for user if it doesn't exists
  def base_user(force_create= false)
    return @base_user if @base_user.present?

    if session.id.nil?
      if force_create
        # if no session exists we need to write something there to create anonymous session
        session[:dummy] = true
        session.delete(:dummy)
      else
        # no session exists, so no stored data for this user yet
        return nil
      end
    end

    if current_user
      # Authenticated user
      attrs = { user: current_user }
    else
      # Not authenticated user
      # We use 'private_id' to have same format as used in Sessions table
      attrs = { session_id: session.id.private_id }
    end

    @base_user = BaseUser.find_by(attrs)
    if @base_user.nil? && force_create
      @base_user = BaseUser.create!(attrs)
    end

    return @base_user
  end

  def set_font_size
    if base_user
      @fontsize = base_user.get_preference(:fontsize)
    else
      @fontsize = BaseUser::DEFAULT_FONT_SIZE
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
  def mobile_search
    render partial: 'shared/mobile_search'
  end
  def es_buckets_to_facet(buckets, codehash)
    facet = {}
    buckets.each do |facethash|
      facet[codehash[facethash['key']]] = facethash['doc_count'] unless codehash[facethash['key']].nil?
    end
    return facet
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
    redirect_to '/', flash: { error: I18n.t(:not_an_editor) }
  end

  def require_admin
    return true if current_user && current_user.admin?
    redirect_to '/', flash: { error: I18n.t(:not_an_admin) }
  end

  def require_user
    return true if current_user
    redirect_to session_login_path, flash: {
      error: I18n.t(:must_be_logged_in) }
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

  def cached_newest_authors
    Rails.cache.fetch("newest_authors", expires_in: 6.hours) do # memoize
      Person.published.has_toc.has_image.left_joins([:expressions, :works]).group('people.id').having("COUNT(works.id) > 0 OR COUNT(expressions.id) > 0").order(published_at: :desc).limit(10)
    end
  end

  def cached_newest_works
    Rails.cache.fetch("newest_works", expires_in: 30.minutes) do # memoize
      Manifestation.published.order(created_at: :desc).limit(10)
    end
  end

  def featured_content
    Rails.cache.fetch("featured_content", expires_in: 10.minutes) do # memoize
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

  def randomize_works_by_genre(genre, how_many)
    return Manifestation.where(id: Manifestation.published.joins(expression: :work).where({ works: { genre: genre } }).pluck(:id).sample(how_many))
  end

  def randomize_works(how_many)
    return Manifestation.where(id: Manifestation.published.pluck(:id).sample(how_many)) # ORDER RAND() is way too slow!
  end

  def cached_authors_in_genre
    Rails.cache.fetch("au_by_genre", expires_in: 24.hours) do # memoize
      ret = {}
      get_genres.each { |g| ret[g] = Person.has_toc.joins(expressions: :work).where(works: { genre: g }).uniq.count }
      ret
    end
  end

  def cached_authors_in_period
    Rails.cache.fetch("au_by_period", expires_in: 24.hours) do # memoize
      ret = {}
      get_periods.each{ |p| ret[p] = Person.has_toc.joins(:expressions).where(expressions: { period: p}).uniq.count}
      ret
    end
  end

  def cached_works_by_period
    Rails.cache.fetch("works_by_period", expires_in: 24.hours) do # memoize
      ret = {}
      get_periods.each{ |p| ret[p] = Manifestation.published.joins(:expression).where(expressions: { period: p}).uniq.count}
      ret
    end
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
    # TODO: cache this!
    #old_toc = @author.toc.toc
    #@toc = @author.toc.refresh_links # TODO: remove this when we're sure we're done with the legacy files
    #if @toc != old_toc # update the TOC if there have been HtmlFiles published since last time, regardless of whether or not further editing would be saved.
    #  @author.toc.toc = @toc
    #  @author.toc.save!
    #end
    @toc = @author.toc.toc
    markdown_toc = toc_links_to_markdown_links(@toc)
    toc_parts = divide_by_genre(markdown_toc)
    @genres_present = toc_parts.shift # first element is the genres array
    @htmls = toc_parts.map{|genre, tocpart| [genre, MultiMarkdown.new(tocpart).to_html.force_encoding('UTF-8')]}
    credits = @author.toc.credit_section || ''
    credits.sub!('## הגיהו', "<div class=\"by-horizontal-seperator-light\"></div>\n\n## הגיהו") unless credits =~ /by-horizontal/
    @credits = MultiMarkdown.new(credits).to_html.force_encoding('UTF-8')
    @credit_section = @author.toc.credit_section.nil? ? "": @author.toc.credit_section
    @toc_timestamp = @author.toc.updated_at
    @works = @author.all_works_title_sorted
    @fresh_works = @author.works_since(12.hours.ago, 1000)
    unless @fresh_works.empty?
      @fresh_works_markdown = @fresh_works.map{|m| "\\n&&& פריט: מ#{m.id} &&& כותרת: #{m.title}#{m.expression.translation ? ' / '+m.authors_string : ''} &&&\\n"}.join('').html_safe
    else
      @fresh_works_markdown = ''
    end
  end

  def is_spider?
    ua = request.user_agent.downcase
    return (SPIDERS.detect{|s| ua.include?(s)} ? true : false)
  end

  def whatsnew_anonymous
    Rails.cache.fetch("whatsnew_anonymous", expires_in: 2.hours) do # memoize
      logger.info("cache miss: calculating whatsnew anonymous")
      return whatsnew_since(1.month.ago)
    end
  end

  def cached_newsfeed
    Rails.cache.fetch("cached_newsfeed", expires_in: 1.hours) do # memoize
      return newsfeed
    end
  end

  def cached_youtube_videos
    Rails.cache.fetch("cached_youtube", expires_in: 24.hours) do # memoize
      # return latest_youtube_videos # commented out due to quote problem, and caching failure yet TBD
      return []
    end
  end

  def latest_youtube_videos
    ret = []
    begin
      channel = Yt::Channel.new id: AppConstants.youtube_channel_id
      vids = channel.videos
      max = vids.count > 5 ? 5 : vids.count
      i = 0
      vids.each{ |v|
        break if i >= max
        ret << [v.title, v.description, v.id, v.thumbnail_url, v.published_at]
        i += 1
      }
    rescue
      puts "No network?"
    end
    return ret
  end

  def youtube_url_from_id(id)
    return 'https://www.youtube.com/watch?v='+id
  end

  public # temp
  def newsfeed
    unsorted_news_items = NewsItem.last(5) # read at most the last 5 persistent news items (Facebook posts, announcements)

    whatsnew_since(1.month.ago).each {|person, pubs| # add newly-published works
      unsorted_news_items << NewsItem.from_publications(person, textify_new_pubs(pubs), pubs, author_toc_path(person.id), person.profile_image.url(:thumb))
    }
    cached_youtube_videos.each {|title, desc, id, thumbnail_url, relevance| # add latest videos
      unsorted_news_items << NewsItem.from_youtube(title, desc, youtube_url_from_id(id), thumbnail_url, relevance)
    }
    # TODO: add latest blog posts
    return unsorted_news_items.sort_by{|item| item.relevance}.reverse # sort by descending relevance
  end

  def whatsnew_since(timestamp)
    authors = {}
    Manifestation.all_published.new_since(timestamp).includes(:expression).each {|m|
      e = m.expression
      next if e.nil? # shouldn't happen
      w = e.work
      person = e.translation ? m.translators.first : m.authors.first # TODO: more nuance
      next if person.nil? # shouldn't happen, but might in a dev. env.
      if authors[person].nil?
        authors[person] = {}
        authors[person][:latest] = 0
      end
      authors[person][w.genre] = [] if authors[person][w.genre].nil?
      authors[person][w.genre] << m
      authors[person][:latest] = m.updated_at if m.updated_at > authors[person][:latest]
    }
    authors
  end

  def textify_titles(manifestations, au) # translations will also include *original* author names, unless the original author is au
    ret = []
    manifestations.each do |m|
      ret << "<a href=\"#{url_for(controller: :manifestation, action: :read, id: m.id)}\">#{m.title}</a>"
      if m.expression.translation
        ret[-1] += ' / ' + m.authors_string unless m.expression.work.authors.include?(au)
      end
    end
    return ret.join('; ')
  end

  def textify_new_pubs(author)
    ret = ''
    author.each do |genre|
      next unless genre[1].class == Array # skip the :latest key
      worksbuf = "<strong>#{I18n.t(genre[0])}:</strong> "
      first = true
      genre[1].each do |m|
        title = m.expression.title
        if m.expression.translation
          per = m.expression.work.persons[0]
          unless per.nil?
            title += " #{I18n.t(:by)} #{per.name}"
          end
        end
        if first
          first = false
        else
          worksbuf += '; '
        end
        worksbuf += "<a href=\"/read/#{m.id}\">#{title}</a>"
      end
      ret += worksbuf+'<br>'
    end
    return ret
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

  def generate_new_anth_name_from_set(anths)
    i = 1
    prefix = I18n.t(:anthology)
    new_anth_name = prefix+"-#{i}"
    anth_titles = @anthologies.pluck(:title)
    loop do
      new_anth_name = prefix+"-#{i}"
      i += 1
      break unless anth_titles.include?(new_anth_name)
    end
    return new_anth_name
  end

  def prep_user_content(context = :manifestation)
    if context == :manifestation
      if base_user.present?
        @bookmark = base_user.bookmarks.where(manifestation: @m).first&.bookmark_p || 0
        @jump_to_bookmarks = base_user.get_preference(:jump_to_bookmarks)
      else
        @bookmark = 0
      end
    end

    if current_user
      @anthologies = current_user.anthologies
      @new_anth_name = generate_new_anth_name_from_set(@anthologies)
      if session[:current_anthology_id].nil?
        unless @anthologies.empty?
          @anthology = @anthologies.first
          session[:current_anthology_id] = @anthology.id
        end
      else
        begin
          @anthology =  Anthology.find(session[:current_anthology_id])
        rescue
          session[:current_anthology_id] = nil # if somehow deleted without resetting the session variable (e.g. during development)
          @anthology = @anthologies.first
        end
      end
      @anthology_select_options = @anthologies.map{|a| [a.title, a.id, @anthology == a ? 'selected' : ''] }
      @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
    end
  end

  helper_method :current_user, :html_entities_coder
end
