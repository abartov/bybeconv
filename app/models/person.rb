include BybeUtils
class Person < ApplicationRecord

  enum gender: %i(male female other unknown)
  enum period: %i(ancient medieval enlightenment revival modern)
  enum status: %i(published unpublished deprecated awaiting_first)

  paginates_per 100

  has_paper_trail ignore: [:impressions_count, :created_at, :updated_at]
  # relationships
  belongs_to :toc
  has_many :featured_contents
  has_many :involved_authorities, class_name: 'InvolvedAuthority', as: :authority
  has_many :works, through: :involved_authorities, class_name: 'Work'
#  has_many :realizers
#  has_many :expressions, through: :realizers, class_name: 'Expression'
  has_many :expressions, through: :involved_authorities, class_name: 'Expression'
  has_many :aboutnesses, as: :aboutable, dependent: :destroy
  has_many :external_links, as: :linkable, dependent: :destroy
  has_many :publications, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_many :collection_items, as: :item

  # scopes
  scope :has_toc, -> { where.not(toc_id: nil) }
  scope :no_toc, -> { where(toc_id: nil) }
  scope :has_image, -> { where.not(profile_image_file_name: nil) }
  scope :no_image, -> { where(profile_image_file_name: nil) }
  scope :bib_done, -> {where(bib_done: true)}
  scope :bib_not_done, -> {where.not(bib_done: true)}
  scope :new_since, -> (since) { where('created_at > ?', since)}
  scope :latest, -> (limit) {order('created_at desc').limit(limit)}
  scope :translators, -> {joins(:involved_authorities).where(involved_authorities: {role: :translator}).distinct}
  scope :translatees, -> {joins(involved_authorities: {work: :expressions}).where(involved_authorities: {role: InvolvedAuthority.roles[:author]}, expressions: {translation: true}).distinct}

  # features
  has_attached_file :profile_image, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, default_url: :placeholder_image_url, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'
  #  has_one_attached :image # ActiveStorage
  #is_impressionable :counter_cache => true # for statistics
  is_impressionable #:counter_cache => true # for statistics
  include CompactedImpressions

  # validations
  validates :name, presence: true
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\z/

  update_index('people'){self} # update PeopleIndex when entity is updated

  # class variable
  @@popular_authors = nil

  # instance methods
  def root_collection
    return @root_collection if @root_collection
    return @root_collection = Collection.find(self.root_collection_id) if self.root_collection_id
    return @root_collection = generate_root_collection!
  end

  def publish!
    # set all person's works to status published
    all_works_including_unpublished.each do |m| # be cautious about publishing joint works, because the *other* author(s) or translators may yet be unpublished!
      next if m.published?
      can_publish = true
      m.authors.each {|au| can_publish = false unless au.published? || au == self}
      m.translators.each {|au| can_publish = false unless au.published? || au == self}
      if can_publish
        m.created_at = Time.now # pretend the works were created just now, so that they appear in whatsnew (NOTE: real creation date can be discovered through papertrail)
        m.status = :published
        m.save!
      end
    end
    self.published_at = Time.now
    self.status = :published
    self.save! # finally, set this person to published
  end

  def publish_if_first!
    if self.awaiting_first?
      self.publish!
    end
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
    bpos = birthdate.strip_hebrew.index('-') # YYYYMMDD or YYYY is assumed
    if bpos.nil?
      if birthdate =~ /\d\d\d+/
        return $&
      else
        return birthdate
      end
    else
      return birthdate[0..bpos-1].strip
    end
  end

  def works_since(since, maxitems)
    o = original_works.where('manifestations.created_at > ?', since).limit(maxitems)
    t = translations.where('manifestations.created_at > ?', since).limit(maxitems)
    joint = (o+t).uniq # NOTE: both of these are manifestations, not works!
    if joint.count > maxitems
      return joint[0..maxitems - 1]
    else
      return joint
    end
  end

  def cached_works_count
    Rails.cache.fetch("au_#{self.id}_work_count", expires_in: 24.hours) do
      created_work_ids = self.works.includes(expressions: [:manifestations]).where(manifestations: {status: :published}).pluck(:id)
      expressions_work_ids = self.expressions.includes(:manifestations).where(manifestations: {status: :published}).pluck(:work_id)
      (created_work_ids + expressions_work_ids).uniq.size
    end
  end

  def has_any_bibs?
    return self.publications.count > 0
  end

  def has_any_hebrew_works?
    return true if Manifestation.all_published.joins(expression: { work: :involved_authorities }).where(involved_authorities: {authority: self}).where(works: { orig_lang: 'he' }).exists?
    return true if Manifestation.all_published.joins(expression: :involved_authorities).where(involved_authorities: {authority: self, role: :translator}, expressions: { language: 'he' }).exists?
    return false
  end

  def has_any_non_hebrew_works?
    return Manifestation.all_published.joins(expression: { work: :involved_authorities }).where(involved_authorities: {authority: self}).where.not(works: { orig_lang: 'he' }).exists?
  end

  def gender_letter
    return gender == 'female' ? 'ה' : 'ו'
  end

  def favorite_of_user
    return false # TODO: implement when user prefs implemented
  end

  def blog_count
    return 0 # TODO: implement
  end

  def death_year
    return '?' if deathdate.nil?
    dpos = deathdate.strip_hebrew.index('-')
    if dpos.nil?
      if deathdate =~ /\d\d\d+/
        return $&
      else
        return deathdate
      end
    else
      return deathdate[0..dpos-1].strip
    end
  end

  def life_years
    return "#{birth_year}&rlm;-#{death_year}"
  end

  def period_string
    return '' if period.nil?
    return t(period)
  end

  def rights_icon
    # return public_domain ? 'bycc-pd' : 'bycopyright'
    return public_domain ? 'm' : 'x'
  end

  def has_comment?
    return false if comment.nil?
    return false if comment.empty?
    return true
  end

  def all_genres
    works_genres = original_works.select('works.genre').distinct.pluck(:genre)
    translation_genres = translations.select('works.genre').distinct.pluck(:genre)
    return (works_genres + translation_genres).uniq.sort
  end

  def all_languages
    work_langs = original_works.pluck('works.orig_lang')
    #translation_langs = translations.pluck('works.orig_lang')
    #all_languages = work_langs + translation_langs
    #return all_languages.uniq
    return work_langs.uniq
  end

  def original_works
    Manifestation.all_published.joins(expression: [work: :involved_authorities]).where("involved_authorities.authority_id = #{self.id} and involved_authorities.authority_type = 'Person'")
  end

  def translations
    Manifestation.all_published.joins(expression: [:work, :involved_authorities]).includes(expression: [work: :involved_authorities]).where(involved_authorities: {role: :translator, authority: self})
  end

  def all_works_including_unpublished
    works = Manifestation.joins(expression: [work: :involved_authorities]).includes(:expression).where("involved_authorities.authority_id = #{self.id} and involved_authorities.authority_type = 'Person'")
    xlats = Manifestation.joins(expression: :involved_authorities).includes(expression: [work: :involved_authorities]).where(involved_authorities:{role: :translator, authority: self})
    (works + xlats).uniq.sort_by{|m| m.sort_title}
  end

  def original_work_count_including_unpublished
    Manifestation.joins(expression: { work: :involved_authorities }).where(involved_authorities: {authority: self}).count
  end

  def translations_count_including_unpublished
    Manifestation.joins(expression: :involved_authorities).where(involved_authorities: {authority: self, role: :translator}).count
  end

  def all_works_title_sorted
    (original_works + translations).uniq.sort_by{|m| m.sort_title}
  end

  def all_works_by_order(order)
    (original_works.order(order) + translations.order(order)).uniq
  end

  def all_works_by_title(term)
    w = original_works.where('expressions.title like ?', "%#{term}%")
    t = translations.where('expressions.title like ?', "%#{term}%")
    return (w + t).uniq.sort_by{|m| m.sort_title}
  end

  def original_works_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.all_published.joins(expression: [work: :involved_authorities]).includes(:expression).where("involved_authorities.authority_id = #{self.id} and involved_authorities.authority_type = 'Person'").each do |m|
      ret[m.expression.work.genre] << m
    end
    return ret
  end

  def translations_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.all_published.joins(expression: :involved_authorities).includes(expression: :work).where(involved_authorities:{role: :translator, authority: self}).each do |m|
      ret[m.expression.work.genre] << m
    end
    return ret
  end

  def featured_work
    Rails.cache.fetch("au_#{self.id}_featured", expires_in: 24.hours) do # memoize
      self.featured_contents.order(Arel.sql('RAND()')).limit(1)
    end
  end

  def latest_stuff
    latest_original_works = Manifestation.all_published.joins(expression: [work: :involved_authorities]).includes(:expression).where("involved_authorities.authority_id = #{self.id} and involved_authorities.authority_type = 'Person'").order(created_at: :desc).limit(20)

    latest_translations = Manifestation.all_published.joins(expression: :involved_authorities).includes(expression: [work: :involved_authorities]).where(involved_authorities:{role: :translator, authority: self}).order(created_at: :desc).limit(20)

    return (latest_original_works + latest_translations).uniq.sort_by{|m| m.created_at}.reverse.first(20)
  end

  def cached_latest_stuff
    Rails.cache.fetch("au_#{self.id}_latest_stuff", expires_in: 24.hours) do
      latest_stuff
    end
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
      Manifestation.joins(expression: { work: :involved_authorities }).where(involved_authorities: {authority: self}).
        order(impressions_count: :desc).
        limit(limit).map do |m|
          {
            id: m.id,
            title: m.title,
            author: m.authors_string,
            translation: m.expression.translation,
            genre: m.expression.work.genre
          }
        end
    end
  end

  def copyright_as_string
    return public_domain ? I18n.t(:public_domain) : I18n.t(:by_permission)
  end

  # class methods
  def self.cached_translators_count
    Rails.cache.fetch("au_translators_count", expires_in: 24.hours) do
      self.translators.count
    end
  end

  def self.cached_count
    Rails.cache.fetch("au_total_count", expires_in: 24.hours) do
      self.count
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

  def self.get_popular_authors_by_genre(genre)
    Rails.cache.fetch("au_pop_in_#{genre}", expires_in: 24.hours) do # memoize
      Person.has_toc.joins(expressions: :work).where(works: { genre: genre }).order(impressions_count: :desc).distinct.limit(10).all.to_a # top 10
    end
  end

  def self.get_popular_translators
    Rails.cache.fetch("au_pop_translators", expires_in: 24.hours) do # memoize
      Person.joins(:involved_authorities).where(involved_authorities: {role: :translator}).order(impressions_count: :desc).distinct.limit(10)
    end
  end

  def self.recalc_popular
    @@popular_authors = Person.has_toc.order(impressions_count: :desc).limit(10).all.to_a # top 10 #TODO: make it actually about *most-read* authors, rather than authors whose *TOC* is most-read
  end

  def self.recalc_recommendation_counts
    Person.has_toc.each do |p|
      # TODO: implement
    end
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

  def generate_root_collection!
    works = toc.present? ? toc.linked_items : []
    colls = Collection.by_authority(self).where.not(collection_type: :root) # include any existing collections possibly already defined for this person
    extra_works = self.all_works_including_unpublished.reject{|m| works.include?(m)}
    c = nil
    ActiveRecord::Base.transaction do
      c = Collection.create!(title: self.name, status: :published, collection_type: :root, toc_strategy: :default)
      self.root_collection_id = c.id
      self.save!
      c.involved_authorities.create!(authority: self, role: :author) # by default
      # make an empty collection per publication (even if one already exists in some other context). Later an editor would populate the empty collection according to an existing manual TOC or a scanned TOC
      pub_colls = []
      publications.each do |pub|
        coll = Collection.create!(title: pub.title, status: :published, collection_type: :volume, toc_strategy: :default)
        pub_colls << coll
      end
      seqno = 0
      [colls, pub_colls, works].each do |arr|
        arr.each do |m|
          ci = CollectionItem.create!(collection: c, item: m, seqno: seqno)
          seqno += 1
        end
      end
      # make a (technical, to-be-reviewed-and-handled) collection out of the works not already linked from the TOC
      extra_works_collection = Collection.create!(title: "#{self.name} - #{I18n.t(:additional_items)}", status: :published, collection_type: :other, toc_strategy: :default)
      extra_seqno = 0
      extra_works.each do |m|
        ci = CollectionItem.create!(collection: extra_works_collection, item: m, seqno: extra_seqno)
        extra_seqno += 1
      end
      CollectionItem.create!(collection: c, item: extra_works_collection, seqno: seqno)
    end
    return c
  end
end
