class Manifestation < ActiveRecord::Base
  is_impressionable :counter_cache => true # for statistics
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_many :taggings
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_many :recommendations

  has_paper_trail
  has_many :external_links
  scope :new_since, -> (since) { where('created_at > ?', since)}

  enum link_type: [:wikipedia, :blog, :youtube, :other]
  enum status: [:approved, :submitted, :rejected]

  update_index 'manifestation#manifestation', :self # update ManifestationIndex when entity is updated

  # class variable
  @@popular_works = nil
  @@tmplock = false

  def long?
    return false # TODO: implement
  end
  def copyright?
    return expressions[0].copyrighted # TODO: implement more generically
  end
  def chapters?
    return false # TODO: implement
  end
  def approved_tags
    return Tag.find(self.taggings.approved.pluck(:tag_id))
  end
  def as_prose?
    # TODO: implement more generically
    return expressions[0].works[0].genre == 'poetry' ? false : true
  end
  def safe_filename
    fname = "#{title} #{I18n.t(:by)} #{expressions[0].persons[0].name}"
    return fname.gsub(/[^0-9א-תA-Za-z.\-]/, '_')
  end
  def title_and_authors
    return title + ' / '+author_string
  end
  def author_string
    return I18n.t(:nil) if expressions[0].nil? or expressions[0].works[0].nil? or expressions[0].works[0].persons[0].nil?
    ret = expressions[0].works[0].persons[0].name
    if expressions[0].translation
      ret += ' / '+expressions[0].persons[0].name
    end
    return ret # TODO: be less naive
  end

  def recalc_cached_people!
     pp = []
     expressions.each {|e|
       e.persons.each {|p| pp << p unless pp.include?(p) }
       e.works.each {|w|
         w.persons.each {|p| pp << p unless pp.include?(p) }
       }
     }
     cached_people = pp.map{|p| p.name}.join('; ')
     save!
  end

  def self.recalc_popular

    @@popular_works = Manifestation.order(impressions_count: :desc).limit(10) # top 10

    # old code without cache_counter
    ## THIS WILL TAKE A WHILE!
    ## it runs a JOIN on every single publishedManifestation!
    ## It is designed to only be called no more than once a day, by clockwork!
    #work_stats = {}
    #Manifestation.all.each {|m|
    #  work_stats[m] = m.impressions.count
    #}
    #bottom_works = work_stats.sort_by {|k,v| v}
    #@@popular_works = bottom_works.reverse[0..9] # top 10
  end

  def self.get_popular_works
    if @@popular_works == nil # TODO: implement race-condition protect with tmplock
      self.recalc_popular
    end
    return @@popular_works
  end
end
