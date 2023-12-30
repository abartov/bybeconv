class Collection < ApplicationRecord
  before_save :update_sort_title!

  belongs_to :publication
  belongs_to :toc
  has_many :collection_items, -> { order(:seqno) }, dependent: :destroy

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
end
