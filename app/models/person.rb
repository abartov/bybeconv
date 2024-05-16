include BybeUtils
class Person < ApplicationRecord
  enum gender: %i(male female other unknown)
  enum period: %i(ancient medieval enlightenment revival modern)
  has_one :authority, inverse_of: :person, dependent: :destroy

  scope :with_name, -> { joins(:authority).select('people.*, authorities.name') }

  has_paper_trail

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

  def gender_letter
    return gender == 'female' ? 'ה' : 'ו'
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

  def generate_root_collection!
    works = toc.present? ? toc.linked_items : []
    colls = Collection.by_authority(self).where.not(collection_type: :root) # include any existing collections possibly already defined for this person
    extra_works = self.all_works_including_unpublished.reject{|m| works.include?(m)}
    c = nil
    ActiveRecord::Base.transaction do
      c = Collection.create!(title: self.name, collection_type: :root, toc_strategy: :default)
      self.root_collection_id = c.id
      self.save!
      c.involved_authorities.create!(authority: self, role: :author) # by default
      # make an empty collection per publication (even if one already exists in some other context). Later an editor would populate the empty collection according to an existing manual TOC or a scanned TOC
      pub_colls = []
      publications.each do |pub|
        coll = Collection.create!(title: pub.title, collection_type: :volume, toc_strategy: :default)
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
      extra_works_collection = Collection.create!(title: "#{self.name} - #{I18n.t(:additional_items)}", collection_type: :other, toc_strategy: :default)
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
