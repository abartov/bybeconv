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
  has_many :involved_authorities, dependent: :destroy, inverse_of: :person

  has_many :aboutnesses, as: :aboutable, dependent: :destroy
  has_many :external_links, as: :linkable, dependent: :destroy
  has_many :publications, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'

  enum intellectual_property: {
    public_domain: 0,
    copyrighted: 2,
    orphan: 3,
    permission_for_all: 4,
    permission_for_selected: 5,
    unknown: 100
  }, _prefix: true

  # scopes
  scope :has_toc, -> { where.not(toc_id: nil) }
  scope :no_toc, -> { where(toc_id: nil) }
  scope :has_image, -> { where.not(profile_image_file_name: nil) }
  scope :no_image, -> { where(profile_image_file_name: nil) }
  scope :bib_done, -> {where(bib_done: true)}
  scope :bib_not_done, -> {where("bib_done is null OR bib_done = 0")}
  scope :new_since, -> (since) { where('created_at > ?', since)}
  scope :latest, -> (limit) {order('created_at desc').limit(limit)}
  scope :tagged_with, -> (tag_id) {joins(:taggings).where(taggings: {tag_id: tag_id, status: Tagging.statuses[:approved]}).distinct}

  # features
  has_attached_file :profile_image, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, default_url: :placeholder_image_url, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'
  #  has_one_attached :image # ActiveStorage
  #is_impressionable :counter_cache => true # for statistics
  is_impressionable #:counter_cache => true # for statistics
  include CompactedImpressions

  # validations
  validates :name, :intellectual_property, presence: true

  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\z/

  update_index('people'){self} # update PeopleIndex when entity is updated

  # class variable
  @@popular_authors = nil

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

  def approved_tags
    approved_taggings.joins(:tag).where(tag: {status: Tag.statuses[:approved]} ).map{|x| x.tag}
  end

  def approved_taggings
    taggings.where(status: Tagging.statuses[:approved])
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

  # @param roles [String / Symbol] optional, if provided will only return Manifestations where person has
  #   one of the given roles.
  # @return relation representing [Manifestation] objects current person is involved into.
  def manifestations(*roles)
    rel = involved_authorities
    rel = rel.where(role: roles.to_a) if roles.present?
    ids = rel.pluck(:work_id, :expression_id)

    work_ids = ids.map(&:first).compact.uniq
    expression_ids = ids.map(&:last).compact.uniq

    Manifestation.joins(:expression)
                 .where('expressions.work_id in (?) or expressions.id in (?)', work_ids, expression_ids)
  end

  # Works like {#manifestaions} method, but returns only published manifestations
  def published_manifestations(*roles)
    manifestations(*roles).all_published
  end

  def cached_works_count
    Rails.cache.fetch("au_#{self.id}_work_count", expires_in: 24.hours) do
      published_manifestations.count
    end
  end

  def has_any_bibs?
    return self.publications.count > 0
  end

  def has_any_hebrew_works?
    return true if Manifestation.all_published
                                .joins(expression: { work: :involved_authorities })
                                .merge(InvolvedAuthority.role_author.where(person_id: id))
                                .exists?(works: { orig_lang: 'he' })

    return true if Manifestation.all_published
                                .joins(expression: :involved_authorities)
                                .merge(InvolvedAuthority.role_translator.where(person_id: id))
                                .exists?(expressions: { language: 'he' })

    return false
  end

  def has_any_non_hebrew_works?
    return Manifestation.all_published
                        .joins(expression: { work: :involved_authorities })
                        .merge(InvolvedAuthority.role_author.where(person_id: id))
                        .where.not(works: { orig_lang: 'he' })
                        .exists?
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

  def has_comment?
    return false if comment.nil?
    return false if comment.empty?
    return true
  end

  def all_genres
    published_manifestations(:author, :translator).joins(expression: :work)
                                                  .select('works.genre')
                                                  .distinct
                                                  .pluck(:genre)
                                                  .sort
  end

  def all_languages
    work_langs = original_works.joins(expression: :work).pluck('works.orig_lang')
    #translation_langs = translations.pluck('works.orig_lang')
    #all_languages = work_langs + translation_langs
    #return all_languages.uniq
    return work_langs.uniq
  end

  def original_works
    published_manifestations(:author)
  end

  def translations
    published_manifestations(:translator)
  end

  def all_works_including_unpublished
    manifestations(:author, :translator).sort_by(&:sort_title)
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

  def title # convenience method for polymorphic handling (e.g. Taggable)
    name
  end

  def original_works_by_genre
    hash = published_manifestations(:author).preload(expression: :work)
                                            .group_by { |m| m.expression.work.genre }
    Work::GENRES.index_with { |genre| hash[genre] || [] }
  end

  def translations_by_genre
    hash = published_manifestations(:translator).preload(expression: :work)
                                                .group_by { |m| m.expression.work.genre }
    Work::GENRES.index_with { |genre| hash[genre] || [] }
  end

  def featured_work
    Rails.cache.fetch("au_#{self.id}_featured", expires_in: 24.hours) do # memoize
      self.featured_contents.order(Arel.sql('RAND()')).limit(1)
    end
  end

  def latest_stuff
    published_manifestations(:author, :translator).order(created_at: :desc).limit(20).to_a
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
      Manifestation.joins(expression: { work: :involved_authorities })
                   .merge(InvolvedAuthority.role_author.where(person_id: id))
                   .order(impressions_count: :desc)
                   .limit(limit).map do |m|
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

  def cached_popular_tags_used_on_works
    Rails.cache.fetch("au_#{self.id}_pop_tags", expires_in: 12.hours) do
      popular_tags_used_on_works
    end
  end

  def popular_tags_used_on_works(limit=10)
    Tag.find(popular_tags_used_on_works_with_count.keys.first(limit))
  end

  def popular_tags_used_on_works_with_count
    mm = (original_works + translations).uniq.pluck(:id)
    Tag.joins(:taggings).where(taggings: {taggable_type: 'Manifestation', taggable_id: mm}).group('tags.id').order('count_all DESC').count
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
end
