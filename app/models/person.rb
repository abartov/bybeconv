include BybeUtils
class Person < ActiveRecord::Base
  attr_accessible :affiliation, :comment, :country, :name, :nli_id, :other_designation, :viaf_id, :public_domain, :profile_image, :birthdate, :deathdate, :wikidata_id, :wikipedia_url, :wikipedia_snippet, :blog_category_url, :profile_image, :metadata_approved, :gender

  enum gender: [:male, :female, :other, :unknown]

  # relationships
  belongs_to :toc
  belongs_to :period
  has_many :creations
  has_many :works, through: :creations, class_name: 'Work'
  has_many :realizers
  has_many :expressions, through: :realizers, class_name: 'Expression'

  has_and_belongs_to_many :manifestations

  # scopes
  scope :has_toc, -> { where.not(toc_id: nil) }
  scope :no_toc, -> { where(toc_id: nil) }
  scope :in_genre, -> (genre) {has_toc.joins(:expressions).where(expressions: { genre: genre}).distinct}
  scope :new_since, -> (since) { where('created_at > ?', since)}
  scope :latest, -> (limit) {order('created_at desc').limit(limit)}
  scope :translators, -> {joins(:realizers).where(realizers: {role: Realizer.roles[:translator]}).distinct}
  scope :translatees, -> {joins(creations: {work: :expressions}).where(creations: {role: Creation.roles[:author]}, expressions: {translation: true}).distinct}

  # features
  has_attached_file :profile_image, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, default_url: :placeholder_image_url, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'
  is_impressionable :counter_cache => true # for statistics
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\z/

  # class variable
  @@popular_authors = nil

  def self.person_by_viaf(viaf_id)
    Person.find_by_viaf_id(viaf_id)
  end

  def self.create_or_get_person_by_viaf(viaf_id)
    p = Person.person_by_viaf(viaf_id)
    if p.nil?
      viaf_record = viaf_record_by_id(viaf_id)
      fail Exception if viaf_record.nil?
      #debugger
      bdate = viaf_record['birthDate'].nil? ? '?' : viaf_record['birthDate'].encode('utf-8')
      ddate = viaf_record['deathDate'].nil? ? '?' : viaf_record['deathDate'].encode('utf-8')
      datestr = bdate+'-'+ddate
      p = Person.new(dates: datestr, name: viaf_record['labels'][0].encode('utf-8'), viaf_id: viaf_id, birthdate: bdate, deathdate: ddate)
      p.save!
    end
    p
  end

  def died_years_ago
    begin
      dy = death_year.to_i
      return Date.today.year - dy
    rescue
      return 0
    end
  end

  def birth_year
    return '?' if birthdate.nil?
    bpos = birthdate.index('-') # YYYYMMDD or YYYY is assumed
    if bpos.nil?
      if birthdate =~ /\d\d\d+/
        return $&
      else
        return birthdate
      end
    else
      return birthdate[0..bpos-1]
    end
  end

  def works_since(since, maxitems)
    o = original_works.where('created_at > ?', since)
    t = translations.where('created_at > ?', since)
    joint = (o+t).uniq
    if joint.count > maxitems
      return joint[0..maxitems - 1]
    else
      return joint
    end
  end

  def cached_works_count
    Rails.cache.fetch("au_#{self.id}_work_count", expires_in: 24.hours) do
      self.expressions.count
    end
  end

  def self.cached_translators_count
    Rails.cache.fetch("au_translators_count", expires_in: 24.hours) do
      self.translators.count
    end
  end

  def self.cached_toc_count
    Rails.cache.fetch("au_toc_count", expires_in: 24.hours) do
      self.has_toc.count
    end
  end

  def self.cached_pd_count
    Rails.cache.fetch("au_pd_count", expires_in: 24.hours) do
      self.has_toc.where(public_domain: true).count
    end
  end

  def self.cached_no_toc_count
    Rails.cache.fetch("au_no_toc_count", expires_in: 24.hours) do
      self.no_toc.count
    end
  end

  def gender_letter
    return gender == 'female' ? 'ה' : 'ו'
  end

  def blog_count
    return 0 # TODO: implement
  end

  def death_year
    return '?' if deathdate.nil?
    dpos = deathdate.index('-')
    if dpos.nil?
      if deathdate =~ /\d\d\d+/
        return $&
      else
        return deathdate
      end
    else
      return deathdate[0..dpos-1]
    end
  end

  def life_years
    return "#{birth_year}&rlm;-#{death_year}"
  end

  def period_string
    return '' if period.nil?
    return period.name
  end

  def rights_icon
    return public_domain ? 'bycc-pd' : 'bycopyright'
  end

  def has_comment?
    return false if comment.nil?
    return false if comment.empty?
    return true
  end

  def original_works
    Manifestation.joins(expressions: [works: :creations]).includes(:expressions).where("creations.person_id = #{self.id}")
  end

  def translations
    Manifestation.joins(expressions: :realizers).includes(expressions: [works: [creations: :person]]).where(realizers:{role: Realizer.roles[:translator], person_id: self.id})
  end

  def all_works_title_sorted
    (original_works + translations).uniq.sort_by{|m| m.title}
  end

  def all_works_by_order(order)
    (original_works.order(order) + translations.order(order)).uniq
  end

  def all_works_by_title(term)
    w = original_works.where("expressions.title like '%#{term}%'")
    t = translations.where("expressions.title like '%#{term}%'")
    return (w + t).uniq.sort_by{|m| m.title}
  end

  def original_works_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.joins(expressions: [works: :creations]).includes(:expressions).where("creations.person_id = #{self.id}").each do |m|
      ret[m.expressions[0].genre] << m
    end
    return ret
  end

  def translations_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.joins(expressions: :realizers).includes(expressions: [works: [creations: :person]]).where(realizers:{role: Realizer.roles[:translator], person_id: self.id}).each do |m|
      ret[m.expressions[0].genre] << m
    end
    return ret
  end

  def cached_original_works_by_genre
    Rails.cache.fetch("au_#{self.id}_original_works_by_genre", expires_in: 24.hours) do
      original_works_by_genre
    end
  end

  def cached_translations_by_genre
    Rails.cache.fetch("au_#{self.id}_translations_by_genre", expires_in: 24.hours) do
      translations_by_genre
    end
  end

  def most_read(limit)
    Rails.cache.fetch("au_#{self.id}_#{limit}_most_read", expires_in: 24.hours) do
      self.manifestations.includes(:expressions).order(impressions_count: :desc).limit(limit).map{|m| {id: m.id, title: m.title, author: m.author_string, translation: m.expressions[0].translation, genre: m.expressions[0].genre }}
    end
  end

  def copyright_as_string
    return public_domain ? I18n.t(:public_domain) : I18n.t(:by_permission)
  end

  def self.get_popular_authors_by_genre(genre)
    Rails.cache.fetch("au_pop_in_#{genre}", expires_in: 24.hours) do # memoize
      Person.has_toc.joins(:expressions).where(expressions: { genre: genre}).order(impressions_count: :desc).distinct.limit(10).all.to_a # top 10
    end
  end

  def self.get_popular_translators
    Rails.cache.fetch("au_pop_translators", expires_in: 24.hours) do # memoize
      Person.joins(:realizers).where(realizers: {role: Realizer.roles[:translator]}).order(impressions_count: :desc).distinct.limit(10)
    end
  end

  def self.get_popular_xlat_authors
    Rails.cache.fetch("au_pop_xlat", expires_in: 24.hours) do # memoize
      Person.joins(creations: {work: :expressions}).where(creations: {role: Creation.roles[:author]}, expressions: {translation: true}).order(impressions_count: :desc).distinct
    end
  end

  def self.get_popular_xlat_authors_by_genre(genre)
    Rails.cache.fetch("au_pop_xlat_in_#{genre}", expires_in: 24.hours) do # memoize
      Person.joins(creations: {work: :expressions}).where(creations: {role: Creation.roles[:author]}, expressions: { genre:genre, translation: true}).order(impressions_count: :desc).distinct.limit(10).all.to_a # top 10
    end
  end

  def self.recalc_popular
    @@popular_authors = Person.has_toc.order(impressions_count: :desc).limit(10).all.to_a # top 10 #TODO: make it actually about *most-read* authors, rather than authors whose *TOC* is most-read
  end

  def self.get_popular_authors
    if @@popular_authors == nil
      self.recalc_popular
    end
    return @@popular_authors
  end
  protected
  def placeholder_image_url
    if gender == 'female'
      return '/assets/:style/placeholder_woman.jpg'
    else
      return '/assets/:style/placeholder_man.jpg'
    end
  end
end
