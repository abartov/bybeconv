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

  def authors
    return [] if item.nil?

    item.authors
  end

  def title_and_authors
    ret = title
    return ret if item.blank?

    as = item.authors_string
    ret += " #{I18n.t(:by)} #{as}" if as.present?
    ret
  end

  def title_and_authors_html
    ret = "<h1>#{title}</h1>"
    return ret if item.blank?

    as = item.authors_string
    ret += "#{I18n.t(:by)}<h2>#{as}</h2>" if as.present?
    ret
  end

  def is_collection?
    item.is_a?(Collection)
  end

  def genre
    return item.genre if item.present? && item.respond_to?(:genre)

    return 'paratext' if markdown.present?

    return ''
  end

  def to_html
    if item.present?
      return item.to_html
    end
    return '' if markdown.blank?

    return MultiMarkdown.new(markdown).to_html
  end

  # return list of genres in included items
  def included_genres
    return [item.expression.work.genre] if item_type == 'Manifestation'

    return item.included_genres if item.respond_to?(:included_genres) # sub-collections

    return []
  end

  # return list of copyright statuses in included items
  def intellectual_property_statuses
    return [item.expression.intellectual_property] if item_type == 'Manifestation'

    return item.intellectual_property_statuses if item.respond_to?(:intellectual_property_statuses) # sub-collections

    return []
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
