class NewsItem < ApplicationRecord
  enum :itemtype, { publication: 0, facebook: 1, youtube: 2, blog: 3, announcement: 4, recommendation: 5 }

  scope :new_since, ->(since) { where('created_at > ?', since) }

  # itemtype, title, pinned, relevance, body, url, double,
  attr_accessor :authority_id, :pub_count

  def self.from_publications(authority, textified_pubs, pubs, url, thumbnail_url)
    total_pubs = pubs.each_key.map { |g| g == :latest ? 0 : pubs[g].count }.sum
    return NewsItem.new(
      itemtype: :publication,
      title: authority.name,
      body: textified_pubs,
      relevance: pubs[:latest],
      url: url,
      thumbnail_url: thumbnail_url,
      authority_id: authority.id,
      pub_count: total_pubs
    )
  end

  def self.from_blog(title, text, url, relevance)
    # TODO: implement
  end

  def self.from_youtube(title, text, url, thumbnail_url, relevance)
    return NewsItem.new(itemtype: :youtube, title: title, body: text, url: url, thumbnail_url: thumbnail_url,
                        relevance: relevance)
  end
end
