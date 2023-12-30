class Collection < ApplicationRecord
  before_save :update_sort_title!

  belongs_to :publication
  belongs_to :toc
  has_many :collection_items, -> { order(:seqno) }, dependent: :destroy

  has_many :creations, dependent: :destroy
  has_many :persons, through: :creations, class_name: 'Person'
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
  # series express anything from a cycle of poems to a multi-volume work or a series of detective novels; anthologies are collections of texts by multiple authors, such as festschrifts, almanacs, or collective anthologies; periodicals are journals, magazines, newspapers, etc., where there is a known sequence of issues; periodical issues are individual issues of a periodical; series items are individual items in a series, such as a single volume in a multi-volume work; other is a catch-all for anything else
  enum collection_type: [:anthology, :periodical, :periodical_issue, :series, :series_item, :other]
  enum toc_strategy: [:default, :custom_markdown] # placeholder for future custom ToC-generation strategies

  scope :published, -> { where(status: Collection.statuses[:published]) }
  scope :by_type, -> (thetype) { where(collection_type: thetype) }
  scope :by_tag, ->(tag_id) {joins(:taggings).where(taggings: {tag_id: tag_id})}

  def collection_items_by_type(item_type)
    self.collection_items.where(item_type: item_type)
  end

  def items_by_type(item_type)
    self.collection_items_by_type(item_type).map(&:item)
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
    ci = CollectionItem.new(collection: self, item: item)
    ci.seqno = self.collection_items.maximum(:seqno).to_i + 1
    ci.save!
  end
  
end
