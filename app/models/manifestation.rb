class Manifestation < ActiveRecord::Base
  is_impressionable # for statistics
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_many :taggings
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_many :recommendations

  has_paper_trail
  has_many :external_links
  scope :new_since, -> (since) { where('created_at > ?', since)}

  # class variable
  @@popular_works = nil

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
    fname = "#{title} #{I18n.t(:by)} #{expressions[0].people[0].name}"
    return fname.gsub(/[^0-9א-תA-Za-z.\-]/, '_')
  end
  def title_and_authors
    return title + ' / '+author_string
  end
  def author_string
    ret = expressions[0].works[0].people[0].name
    if expressions[0].translation
      ret += ' / '+expressions[0].people[0].name
    end
    return ret # TODO: be less naive
  end
  def self.recalc_popular
    # THIS WILL TAKE A WHILE!
    # it runs a JOIN on every single publishedManifestation!
    # It is designed to only be called no more than once a day, by clockwork!
    work_stats = {}
    Manifestation.all.each {|m|
      work_stats[m] = m.impressions.count
    }
    top_works = work_stats.sort_by {|k,v| v}
    @@popular_works = top_works[0..9] # top 10
  end

  def self.get_popular_works
    if @@popular_works == nil
      self.recalc_popular
    end
    return @@popular_works
  end
end
