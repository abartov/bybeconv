class NewsItem < ApplicationRecord
  enum itemtype: %i(publication facebook youtube blog announcement recommendation)
  include Rails.application.routes.url_helpers

  scope :new_since, -> (since) { where('created_at > ?', since)}

  # itemtype, title, pinned, relevance, body, url, double,

  def self.from_publications(person, textified_pubs, pubs, url, thumbnail_url)
    return NewsItem.new(itemtype: :publication, title: person.name, body: textified_pubs, relevance: pubs[:latest], url: url, thumbnail_url: thumbnail_url)
  end

  def self.from_blog(title, text, url, relevance)
    # TODO: implement
  end

  def self.from_youtube(title, text, url, thumbnail_url, relevance)
    return NewsItem.new(itemtype: :youtube, title: title, body: text, url: url, thumbnail_url: thumbnail_url, relevance: relevance)
  end

end
