include BybeUtils
class Person < ActiveRecord::Base
  attr_accessible :affiliation, :comment, :country, :name, :nli_id, :other_designation, :viaf_id, :public_domain, :profile_image, :birthdate, :deathdate, :wikidata_id, :wikipedia_url, :wikipedia_snippet, :profile_image, :metadata_approved, :gender

  enum gender: [:male, :female, :other, :unknown]

  # relationships
  belongs_to :toc
  belongs_to :period
  has_many :creations
  has_many :works, through: :creations, class_name: 'Work'
  has_many :realizers
  has_and_belongs_to_many :manifestation

  # scopes
  scope :has_toc, -> { where.not(toc_id: nil) }

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

  def death_year
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

  def has_comment?
    return false if comment.nil?
    return false if comment.empty?
    return true
  end

  def  copyright_as_string
    return public_domain ? I18n.t(:public_domain) : I18n.t(:by_permission)
  end

  def self.recalc_popular
    @@popular_authors = Person.has_toc.order(impressions_count: :desc).limit(10) # top 10

    # old code before counter cache
    ## this is designed to only be called no more than once a day, by clockwork!
    #author_stats = {}
    #Person.has_toc.each {|p| # gather stats per author with ToC
    #  author_stats[p] = p.impressions.count
    #}
    #bottom_authors = author_stats.sort_by {|k,v| v}
    #@@popular_authors = bottom_authors.reverse[0..9] # top 10
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
