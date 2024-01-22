class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :item, polymorphic: true

  validates_presence_of :collection, :seqno

  def title
    if self.item.nil?
      self.alt_title
    else
      self.item.title
    end
  end

  def paratext?
    self.item.nil? && self.markdown.present?
  end
end