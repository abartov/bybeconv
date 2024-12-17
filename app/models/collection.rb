# frozen_string_literal: true

# Heterogeneous collection
class Collection < ApplicationRecord
  SYSTEM_TYPES = %w(uncollected root).freeze

  include RecordWithInvolvedAuthorities

  update_index('collections') { self }

  before_save :update_sort_title!

  validates :collection_type, presence: true

  belongs_to :publication
  belongs_to :toc
  has_many :collection_items, -> { order(:seqno) }, inverse_of: :collection, dependent: :destroy

  has_many :aboutnesses, as: :aboutable, dependent: :destroy # works that are ABOUT this collection
  # has_many :topics, class_name: 'Aboutness', dependent: :destroy # topics that this work is ABOUT
  has_many :downloadables, as: :object, dependent: :destroy

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'
  # TODO: implement
  #  has_many :likings, as: :likeable, dependent: :destroy
  #  has_many :likers, through: :likings, class_name: 'User'

  # convenience methods
  has_many :manifestation_items, through: :collection_items, source: :item, source_type: 'Manifestation'
  has_many :person_items, through: :collection_items, source: :item, source_type: 'Person'
  has_many :work_items, through: :collection_items, source: :item, source_type: 'Work'
  has_many :coll_items, through: :collection_items, source: :item, source_type: 'Collection'

  # enum status: [:published, :nonpd, :unpublished, :deprecated]

  # series express anything from a cycle of poems to a multi-volume work or a series of detective novels;
  # anthologies are collections of texts by multiple authors, such as festschrifts, almanacs,
  #   or collective anthologies;
  # periodicals are journals, magazines, newspapers, etc., where there is a known sequence of issues;
  # periodical issues are individual issues of a periodical; individual items in a series, such as a single volume in
  #   a multi-volume work, are their appropriate type -- a manifestation if a single text, a collection of type volume
  #   if a book, etc.;
  # other is a catch-all for anything else
  # uncollected is used to group authority's works not belonging to any other collections. Each authority can have one.
  enum collection_type: {
    volume: 0,
    periodical: 1,
    periodical_issue: 2,
    series: 3,
    root: 4,
    other: 5,
    uncollected: 100
  }
  enum toc_strategy: { default: 0, custom_markdown: 1 } # placeholder for future custom ToC-generation strategies

  # scope :published, -> { where(status: Collection.statuses[:published]) }
  scope :by_type, ->(thetype) { where(collection_type: thetype) }
  scope :by_tag, ->(tag_id) { joins(:taggings).where(taggings: { tag_id: tag_id }) }
  scope :by_authority, lambda { |authority|
                         joins(:involved_authorities).where(involved_authorities: { authority: authority })
                       }

  validates :title, presence: true

  # Checks if collection is a system-managed collection. We cannot change type of system collection (maybe some
  # other limitations will be added in future)
  def system?
    SYSTEM_TYPES.include?(collection_type)
  end

  def collection_items_by_type(item_type)
    collection_items.where(item_type: item_type)
  end

  def items_by_type(item_type)
    collection_items_by_type(item_type).map(&:item)
  end

  def placeholders
    collection_items.where(item: nil, markdown: nil)
  end

  def title_and_authors
    if authors.present?
      return "#{title} / #{authors_string}"
    elsif editors.present?
      return "#{title} / #{I18n.t(:edited_by)} #{editors_string}"
    else
      return title
    end
  end

  def has_single_text?
    collection_items.where(item_type: 'Manifestation').count == 1
  end

  def title_and_authors_html
    ret = "<h1>#{title}</h1>"
    if authors.present?
      as = authors_string
      ret += "#{I18n.t(:by)}<h2>#{as}</h2>" if as.present?
    elsif editors.present?
      es = editors_string
      ret += "#{I18n.t(:edited_by)}<h2>#{es}</h2>" if es.present?
    end
    ret
  end

  # produce HTML for a table of contents of the collection
  def toc_html
    ret = '<div class="collection_toc"><ul>'
    flatten_items.each do |ci|
      next if ci.item.nil? && ci.markdown.blank? && ci.alt_title.blank?
      if ci.item.nil? && ci.alt_title.present?
        ret += '<li>' + ci.alt_title
      else
        ret += '<li>' + ci.title_and_authors
      end
    end
    ret += '</div>'
    return ret
  end

  def flatten_items
    ret = []
    collection_items.each do |ci|
      ret << ci
      if ci.item.present? && ci.item.instance_of?(Collection)
        ret += ci.item.flatten_items
      end
    end
    return ret
  end

  # this will return the downloadable entity for the Collection *if* it is fresh
  def fresh_downloadable_for(doctype)
    dl = downloadables.where(doctype: doctype).first
    return nil if dl.nil?
    return nil if dl.updated_at < updated_at # needs to be re-generated

    # also ensure none of the collection items is fresher than the saved downloadable
    collection_items.each do |ci|
      return nil if dl.updated_at < ci.updated_at
      return nil if ci.item.present? && (ci.item.updated_at > dl.updated_at)
    end
    return dl
  end

  def to_html(nonce = '')
    return '' if collection_items.count == 0

    html = title_and_authors_html
    i = 0
    collection_items.each do |ci|
      next if ci.item.nil? && ci.markdown.blank?
      html += '<hr/><p/>' + ci.title_and_authors_html
      inner_nonce = "#{nonce}_#{i}"
      html += footnotes_noncer(ci.to_html, inner_nonce)
      i += 1
    end
    return html
  end

  def authors
    auths = involved_authorities_by_role(:author)
    return auths if auths.count > 0

    seen_colls = []
    parent_collections.each do |pc| # iterate until we find authorship
      next if seen_colls.include?(pc.id)

      auths = pc.authors
      return auths if auths.present?

      seen_colls << pc.id
    end

    return []
  end

  def translators
    auths = involved_authorities_by_role(:translator)
    return auths if auths.count > 0

    seen_colls = []
    parent_collections.each do |pc| # iterate until we find authorship
      next if seen_colls.include?(pc.id)

      auths = pc.translators
      return auths if auths.present?

      seen_colls << pc.id
    end

    return []
  end

  def editors
    eds = involved_authorities_by_role(:editor)
    return eds if eds.count > 0

    seen_colls = []
    parent_collections.each do |pc| # iterate until we find editors
      next if seen_colls.include?(pc.id)

      eds = pc.editors
      return eds if eds.present?

      seen_colls << pc.id
    end

    return []
  end

  # return list of genres in included items
  def included_genres
    genres = []
    collection_items.each do |ci|
      genres += ci.included_genres
    end
    return genres.uniq
  end

  # return list of copyright statuses in included items
  def intellectual_property_statuses
    ips = []
    collection_items.each do |ci|
      ips += ci.intellectual_property_statuses
    end
    return ips.uniq
  end

  # return a list of Recommendations for any included items
  def included_recommendations
    recs = []
    collection_items.each do |ci|
      recs += ci.included_recommendations
    end
    return recs.flatten
  end

  def like_count
    return 0
    # TODO: enable after implementing the likings table
    # return likers.count
  end

  # TODO: replace with activerecord association
  def recommendations
    return []
  end

  # return nearest parent volume or periodical_issue
  def parent_volume_or_isssue
    seen_colls = []
    parent_collections.each do |pc| # iterate until we find a volume of collection_type parent or periodical_issue
      next if seen_colls.include?(pc.id)

      return pc if pc.volume? || pc.periodical_issue?

      seen_colls << pc.id
    end
    return nil
  end

  def authorities
    auths = involved_authorities
    return auths if auths.count > 0

    seen_colls = []
    parent_collections.each do |pc| # iterate until we find authorship
      next if seen_colls.include?(pc.id)

      auths = pc.authorities
      return auths if auths.present?

      seen_colls << pc.id
    end

    return []
  end

  def authors_string
    ret = authors.map(&:name).join(', ')

    return ret.presence || I18n.t(:nil)
  end

  def destroy
    collection_items.each do |ci|
      ci.destroy!
    end
    CollectionItem.where(item: self).each { |ci| ci.destroy! } # destroy all references to this collection
    super
  end

  def collection_items_by_role(role, authority_id)
    collection_items.select { |ci| ci.item.present? && ci.item.involved_authorities_by_role(role).any? { |a| a.id == authority_id } }
  end

  def editors_string
    auths = involved_authorities.where(role: 'editor')
    return auths.map(&:authority).map(&:name).join(', ') if auths.count > 0

    parent_collections.each do |pc| # iterate until we find editors
      s = pc.editors_string
      return s if s.present?
    end

    return nil
  end

  def move_item_up(item_id)
    ci = CollectionItem.find(item_id)
    return false if ci.nil?

    prev = collection_items.where('seqno < ?', ci.seqno).last
    return if prev.nil?

    prev.seqno, ci.seqno = ci.seqno, prev.seqno
    prev.save!
    ci.save!
  end

  def move_item_down(item_id)
    ci = CollectionItem.find(item_id)
    return false if ci.nil?

    nxt = collection_items.where('seqno > ?', ci.seqno).first
    return if nxt.nil?

    nxt.seqno, ci.seqno = ci.seqno, nxt.seqno
    nxt.save!
    ci.save!
  end

  def append_item(item)
    ci = collection_item_from_anything(item)
    ci.seqno = collection_items.maximum(:seqno).to_i + 1
    ci.save!
    return ci.id
  end

  def append_collection_item(item)
    item.collection = self
    item.seqno = collection_items.maximum(:seqno).to_i + 1
    item.save!
  end

  def remove_item(item_id)
    ci = collection_items.where(id: item_id).first
    return false if ci.nil?

    ci.destroy!
  end

  def fetch_credits
    return cached_credits if cached_credits.present?

    ret = []
    ret += credits.lines if credits.present?
    collection_items.each do |ci|
      next if ci.item.nil?
      ret += ci.item.credits.lines if ci.item.credits.present?
    end
    ret = ret.map(&:strip).uniq.reject(&:empty?)
    self.cached_credits = ret.join("\n")
    save!
    return cached_credits
  end

  def invalidate_cached_credits!
    self.cached_credits = nil
    save!
  end

  # pos is effective 1-based position in the list, not the seqno (which is not necessarily contiguous!)
  def insert_item_at(item, pos)
    if pos > collection_items.count + 1
      ret = append_item(item)
    else
      before_seqno = pos - 2 < 0 ? 0 : collection_items[pos - 2].seqno
      ci = collection_item_from_anything(item)
      ci.seqno = before_seqno + 1
      collection_items[pos - 1..].each do |coli|
        coli.seqno += 1
        coli.save!
      end
      ci.save!
      ret = ci.id
    end
    return ret
  end

  def apply_drag(coll_item_id, old_pos, new_pos)
    ci = CollectionItem.find(coll_item_id)
    return false if ci.nil?

    if new_pos >= collection_items.count
      ci.seqno = collection_items.maximum(:seqno).to_i + 1
      ci.save!
    elsif old_pos == 1 && new_pos == 2
      old_seqno = ci.seqno
      ci.seqno = collection_items[1].seqno
      collection_items[1].seqno = old_seqno
      ci.save!
      collection_items[1].save!
    else
      before_seqno = new_pos - 2 < 0 ? 0 : collection_items[new_pos - 2].seqno
      ci.seqno = before_seqno + 1
      collection_items[new_pos - 1..].each do |coli|
        coli.seqno += 1
        coli.save!
      end
      ci.save!
    end
  end

  def parent_collections
    parent_collection_items.preload(:collection).map(&:collection)
  end

  # returns collection_items where given collection is specified as an item
  def parent_collection_items
    CollectionItem.where(item: self)
  end

  protected

  def collection_item_from_anything(item)
    # if a string, just create a wrapper item with the string as the alt_title
    if item.instance_of?(String)
      CollectionItem.new(collection: self, alt_title: item)
    elsif item.instance_of?(CollectionItem)
      CollectionItem.new(collection: self, item: item.item, alt_title: item.alt_title, context: item.context,
                         markdown: item.markdown)
    else
      CollectionItem.new(collection: self, item: item)
    end
  end
end
