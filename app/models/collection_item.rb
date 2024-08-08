# frozen_string_literal: true

# Collection item
class CollectionItem < ApplicationRecord
  belongs_to :collection, inverse_of: :collection_items
  belongs_to :item, polymorphic: true

  validates :seqno, presence: true
  validate :ensure_no_cycle

  def title
    if item.nil?
      alt_title
    else
      item.title
    end
  end

  def paratext?
    item.nil? && markdown.present?
  end

  def next_sibling
    CollectionItem.where(collection: collection).where('seqno > ?', seqno).order(:seqno).first
  end

  def prev_sibling
    CollectionItem.where(collection: collection).where('seqno < ?', seqno).order(:seqno).last
  end

  # returns the next sibling that wraps an item, skipping placeholders. and returning count of skipped items
  def next_sibling_item
    skipped = 0
    nxt = self
    loop do
      nxt = nxt.next_sibling
      return nil if nxt.nil?

      return { item: nxt.item, skipped: skipped } unless nxt.item.nil? # placeholders are not items

      skipped += 1
    end
  end

  # returns the previous sibling that wraps an item, skipping placeholders. and returning count of skipped items
  def prev_sibling_item
    skipped = 0
    prv = self
    loop do
      prv = prv.prev_sibling
      return nil if prv.nil?

      return { item: prv.item, skipped: skipped } unless prv.item.nil? # placeholders are not items

      skipped += 1
    end
  end

  protected

  def ensure_no_cycle
    return unless item.is_a?(Collection)

    return unless given_parent?(item)

    errors.add(:collection, :cycle_found)
  end

  def given_parent?(parent_collection)
    return true if collection == parent_collection

    return collection.parent_collection_items.preload(:collection).any? do |ci|
      ci.given_parent?(parent_collection)
    end
  end
end
