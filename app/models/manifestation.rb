include BybeUtils
class Manifestation < ActiveRecord::Base
  is_impressionable :counter_cache => true # for statistics
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people

  has_and_belongs_to_many :likers, join_table: :work_likes, class_name: :User
  has_many :taggings
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_many :recommendations

  has_paper_trail
  has_many :external_links
  scope :new_since, -> (since) { where('created_at > ?', since)}
  scope :pd, -> { joins(:expressions).includes(:expressions).where(expressions: {copyrighted: false})}
  scope :copyrighted, -> { joins(:expressions).includes(:expressions).where(expressions: {copyrighted: true})}
  scope :not_translations, -> { joins(:expressions).includes(:expressions).where(expressions: {translation: false})}
  scope :translations, -> { joins(:expressions).includes(:expressions).where(expressions: {translation: true})}
  scope :genre, -> (genre) { joins(:expressions).includes(:expressions).where(expressions: {genre: genre})}
  enum link_type: [:wikipedia, :blog, :youtube, :other]
  enum status: [:approved, :submitted, :rejected]

  LONG_LENGTH = 15000 # kind of arbitrary...

# re-enable when implementing Chewy
#  update_index 'manifestation#manifestation', :self # update ManifestationIndex when entity is updated

  # class variable
  @@popular_works = nil
  @@tmplock = false

  def like_count
    return likers.count
  end

  def long?
    markdown.length > LONG_LENGTH
  end

  def copyright?
    return expressions[0].copyrighted # TODO: implement more generically
  end

  def heading_lines
    if cached_heading_lines.nil?
      recalc_heading_lines!
    end
    cached_heading_lines.split('|').map{|line| line.to_i}
  end

  def chapters?
    return false if (cached_heading_lines.nil? || cached_heading_lines.empty? || cached_heading_lines[1..5].index('|').nil?)
    return true
  end

  def recalc_heading_lines
    lines = markdown.lines
    temp_heading_lines = []
    lines.each_index {|i| temp_heading_lines << i if lines[i][0..1] == '##' && lines[i][2] != '#' }
    self.cached_heading_lines = temp_heading_lines.join('|')
  end

  def recalc_heading_lines!
    recalc_heading_lines
    save!
  end

  def approved_tags
    return Tag.find(self.taggings.approved.pluck(:tag_id))
  end

  def as_prose?
    # TODO: implement more generically
    return ['poetry','drama'].include?(expressions[0].works[0].genre) ? false : true
  end

  def safe_filename
    fname = "#{title} #{I18n.t(:by)} #{author_string}"
    return fname.gsub(/[^0-9א-תA-Za-z.\-]/, '_')
  end

  def title_and_authors
    return title + ' / '+author_string
  end

  def manual_delete
    expressions.each{|e|
      e.realizers.each{|r| r.destroy!}
      e.works.each{|w|
        w.creations.each{|c| c.destroy!}
        w.destroy!
      }
      e.destroy!
    }
    self.destroy!
  end

  def author_string
    Rails.cache.fetch("m_#{self.id}_author_string", expires_in: 24.hours) do
      return I18n.t(:nil) if expressions[0].nil? or expressions[0].works[0].nil? or expressions[0].works[0].persons[0].nil?
      ret = expressions[0].works[0].persons[0].name
      if expressions[0].translation
        if expressions[0].persons.count < 1
          ret += ' / '+I18n.t(:unknown)
        else
          ret += ' / '+expressions[0].persons[0].name
        end
      end
      return ret # TODO: be less naive
    end
  end

  def recalc_cached_people
     pp = []
     expressions.each {|e|
       e.persons.each {|p| pp << p unless pp.include?(p) }
       e.works.each {|w|
         w.persons.each {|p| pp << p unless pp.include?(p) }
       }
     }
     self.cached_people = pp.map{|p| p.name}.join('; ')
  end

  def recalc_cached_people!
    recalc_cached_people
     save!
  end

  # TODO: calculate this by month
  def self.popular_works_by_genre(genre, xlat)
    if xlat
      Rails.cache.fetch("m_pop_xlat_in_#{genre}", expires_in: 24.hours) do # memoize
        Manifestation.joins([expressions: :works]).includes(:expressions).where(expressions: {genre: genre}).where("works.orig_lang != expressions.language").order(impressions_count: :desc).limit(10).map{|m| {id: m.id, title: m.title, author: m.author_string}}
      end
    else
      Rails.cache.fetch("m_pop_in_#{genre}", expires_in: 24.hours) do # memoize
        Manifestation.joins([expressions: :works]).includes(:expressions).where(expressions: {genre: genre}).where("works.orig_lang = expressions.language").order(impressions_count: :desc).limit(10).map{|m| {id: m.id, title: m.title, author: m.author_string}}
      end
    end
  end

  def self.randomize_in_genre_except(except, genre)
    list = []
    i = 0
    begin
      candidates = Manifestation.genre(genre).order('RAND()').limit(15)
      candidates.each {|au| list << au unless (except.include? au) or (list.include? au) or (list.length == 10)}
      i += 1
    end until list.size >= 10 or i > 10
    return list
  end

  def self.first_25
    Rails.cache.fetch("m_first_25", expires_in: 24.hours) do
      Manifestation.order(:title).limit(25)
    end
  end

  def self.cached_last_month_works
    Rails.cache.fetch("m_new_last_month", expires_in: 24.hours) do
      ret = {}
      Manifestation.new_since(1.month.ago).each {|m|
        e = m.expressions[0]
        genre = e.genre
        person = e.persons[0] # TODO: more nuance
        next if person.nil? || genre.nil? # shouldn't happen, but might in a dev. env.
        ret[genre] = [] if ret[genre].nil?
        ret[genre] << [m.id, m.title, m.author_string]
      }
      ret
    end
  end

  def self.recalc_popular
    @@popular_works = Manifestation.order(impressions_count: :desc).limit(10) # top 10
  end

  def self.cached_popular_works_by_genre
    Rails.cache.fetch("m_pop_by_genre", expires_in: 24.hours) do
      ret = {}
      get_genres.each do |g|
        ret[g] = {}
        ret[g][:orig] = Manifestation.genre(g).not_translations.distinct.order(impressions_count: :desc).limit(10)
        ret[g][:xlat] = Manifestation.genre(g).translations.distinct.order(impressions_count: :desc).limit(10)
      end
      ret
    end
  end

  def self.cached_count
    Rails.cache.fetch("m_count", expires_in: 24.hours) do
      Manifestation.count
    end
  end

  def self.cached_work_counts_by_genre
    Rails.cache.fetch("m_count_by_genre", expires_in: 24.hours) do
      ret = {}
      get_genres.each do |g|
        ret[g] = Manifestation.genre(g).distinct.count
      end
      ret
    end
  end

  def self.cached_translated_count
    Rails.cache.fetch("m_xlat_count", expires_in: 24.hours) do
      Manifestation.translations.count
    end
  end

  def self.cached_pd_count
    Rails.cache.fetch("m_pd_count", expires_in: 24.hours) do
      Manifestation.pd.count
    end
  end

  def self.get_popular_works
    if @@popular_works == nil # TODO: implement race-condition protect with tmplock
      self.recalc_popular
    end
    return @@popular_works
  end
end
