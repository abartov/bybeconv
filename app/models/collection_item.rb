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

  def next_sibling
    CollectionItem.where(collection: self.collection).where("seqno > ?", self.seqno).order(:seqno).first
  end

  def prev_sibling
    CollectionItem.where(collection: self.collection).where("seqno < ?", self.seqno).order(:seqno).last
  end

  # returns the next sibling that wraps an item, skipping placeholders. and returning count of skipped items
  def next_sibling_item
    skipped = 0
    nxt = self
    loop do
      nxt = nxt.next_sibling
      return nil if nxt.nil?
      if nxt.item.nil? # placeholders are not items
        skipped += 1
      else
        return {item: nxt.item, skipped: skipped}
      end
    end
  end

  # returns the previous sibling that wraps an item, skipping placeholders. and returning count of skipped items
  def prev_sibling_item
    skipped = 0
    prv = self
    loop do
      prv = prv.prev_sibling
      return nil if prv.nil?
      if prv.item.nil? # placeholders are not items
        skipped += 1
      else
        return {item: prv.item, skipped: skipped}
      end
    end
  end
end
