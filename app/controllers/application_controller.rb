class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_paper_trail_whodunnit
  after_filter :set_access_control_headers

  def set_access_control_headers
#    headers['Access-Control-Allow-Origin'] = 'http://benyehuda.org/'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

# backup code using Fog, commented out in favor of Paperclip
#  def s3_storage
#    @s3_storage ||= Fog::Storage.new(:provider => 'AWS', :aws_access_key_id => AppConstants.aws_access_key_id, :aws_secret_access_key => AppConstants.aws_secret_access_key)
#  end
#
#  def s3_put(key, localfile)
#    bucket = s3_storage.directories.get(AppConstants.aws_bucket_name)
#    file = bucket.files.create(key: key, body: File.open(localfile), public: true)
#    file.save
#    return file
#  end
#
#  def s3_get(key)
#    bucket = s3_storage.directories.get(AppConstants.aws_bucket_name)
#    file = bucket.files.get(key)
#    return file
#  end

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

  def popular_authors(update = false)
    Person.recalc_popular if update
    @popular_authors = Person.get_popular_authors
  end

  def randomize_authors(exclude_list)
    list = []
    ceiling = [Person.has_toc.count - exclude_list.count - 1, 10].min
    return list if ceiling <= 0
    i = 0
    begin
      candidates = Person.has_toc.order('RAND()').limit(ceiling-list.size) # fetch as many as are still needed
      candidates.each { |author| list << author unless (exclude_list.include? author) or (list.include? author) }
      i += 1
    end until list.size >= ceiling or i > 10 # TODO: fix bug where only one author is retrieved by above block
    return list
  end

  def randomize_works(how_many)
    return Manifestation.order('RAND()').limit(how_many)
  end

  def count_works_by_genre
    ret = {}
    get_genres.each {|g|
      ret[g] = Manifestation.joins(:expressions).where(expressions: {genre: g}).count
    }
    return ret
  end

  def whatsnew_anonymous
    authors = {}
    Manifestation.new_since(1.month.ago).each {|m|
      person = m.expressions[0].persons[0] # TODO: more nuance
      authors[person] = [] if authors[person].nil?
      authors[person] << m
    }
    return authors
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
  helper_method :current_user, :html_entities_coder
end
