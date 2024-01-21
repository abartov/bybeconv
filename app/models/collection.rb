class Collection < ApplicationRecord
  before_save :update_sort_title!

  validates_presence_of :status, :collection_type
  
  belongs_to :publication
  belongs_to :toc
  has_many :collection_items, -> { order(:seqno) }, dependent: :destroy

  has_many :involved_authorities, as: :item, dependent: :destroy
  
  has_many :aboutnesses, as: :aboutable, dependent: :destroy # works that are ABOUT this work
  has_many :topics, class_name: 'Aboutness' # topics that this work is ABOUT 

    # convenience methods
    has_many :manifestation_items, through: :collection_items, source: :item, source_type: 'Manifestation'
    has_many :person_items, through: :collection_items, source: :item, source_type: 'Person'
    has_many :work_items, through: :collection_items, source: :item, source_type: 'Work'
    has_many :coll_items, through: :collection_items, source: :item, source_type: 'Collection'
  
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'

  enum status: [:published, :nonpd, :unpublished, :deprecated]
  # series express anything from a cycle of poems to a multi-volume work or a series of detective novels; anthologies are collections of texts by multiple authors, such as festschrifts, almanacs, or collective anthologies; periodicals are journals, magazines, newspapers, etc., where there is a known sequence of issues; periodical issues are individual issues of a periodical; individual items in a series, such as a single volume in a multi-volume work, are their appropriate type -- a manifestation if a single text, a collection of type volume if a book, etc.; other is a catch-all for anything else
  enum collection_type: [:volume, :periodical, :periodical_issue, :series, :root, :other]
  enum toc_strategy: [:default, :custom_markdown] # placeholder for future custom ToC-generation strategies

  scope :published, -> { where(status: Collection.statuses[:published]) }
  scope :by_type, -> (thetype) { where(collection_type: thetype) }
  scope :by_tag, ->(tag_id) {joins(:taggings).where(taggings: {tag_id: tag_id})}
  scope :by_authority, ->(authority) {joins(:involved_authorities).where(involved_authorities: {authority: authority})}

  def collection_items_by_type(item_type)
    self.collection_items.where(item_type: item_type)
  end

  def items_by_type(item_type)
    self.collection_items_by_type(item_type).map(&:item)
  end
  
  def title_and_authors
    return title + ' / '+authors_string
  end

  def authors_string
    self.involved_authorities.where(role: 'author').map(&:authority).map(&:name).join(', ')
  end
  
  def move_item_up(item_id)
    ci = CollectionItem.find(item_id)
    return false if ci.nil?
    prev = self.collection_items.where("seqno < ?", ci.seqno).last
    return if prev.nil?
    prev.seqno, ci.seqno = ci.seqno, prev.seqno
    prev.save!
    ci.save!
  end

  def move_item_down(item_id)
    ci = CollectionItem.find(item_id)
    return false if ci.nil?
    nxt = self.collection_items.where("seqno > ?", ci.seqno).first
    return if nxt.nil?
    nxt.seqno, ci.seqno = ci.seqno, nxt.seqno
    nxt.save!
    ci.save!
  end

  def append_item(item)
    ci = collection_item_from_anything(item)
    ci.seqno = self.collection_items.maximum(:seqno).to_i + 1
    ci.save!
  end

  def remove_item(item_id)
    ci = self.collection_items.where(id: item_id).first
    return false if ci.nil?
    ci.destroy!
  end

  def insert_item_at(item, pos) # pos is effective 1-based position in the list, not the seqno (which is not necessarily contiguous!)
    if pos > self.collection_items.count + 1
      self.append_item(item)
    else
      before_seqno = pos - 2 < 0 ? 0 : self.collection_items[pos - 2].seqno
      ci = collection_item_from_anything(item)
      ci.seqno = before_seqno + 1
      self.collection_items[pos-1..-1].each do |coli|
        coli.seqno += 1
        coli.save!
      end
      ci.save!
    end
  end

  def apply_drag(coll_item_id, old_pos, new_pos)
    ci = CollectionItem.find(coll_item_id)
    return false if ci.nil?
    if new_pos >= self.collection_items.count
      ci.seqno = self.collection_items.maximum(:seqno).to_i + 1
      ci.save!
    elsif old_pos == 1 && new_pos == 2
      old_seqno = ci.seqno
      ci.seqno = self.collection_items[1].seqno
      self.collection_items[1].seqno = old_seqno
      ci.save!
      self.collection_items[1].save!
    else
      before_seqno = new_pos - 2 < 0 ? 0 : self.collection_items[new_pos - 2].seqno
      ci.seqno = before_seqno + 1
      self.collection_items[new_pos-1..-1].each do |coli|
        coli.seqno += 1
        coli.save!
      end
      ci.save!
    end
  end

  def parent_collections
    CollectionItem.where(item: self).map(&:collection)
  end
  protected
  def collection_item_from_anything(item)
    # if a string, just create a wrapper item with the string as the alt_title
    if item.class == String 
      CollectionItem.new(collection: self, alt_title: item)
    elsif item.class == CollectionItem
      CollectionItem.new(collection: self, item: item.item, alt_title: item.alt_title, context: item.context)
    else
      CollectionItem.new(collection: self, item: item)
    end
  end
end
