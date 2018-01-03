class StaticPage < ActiveRecord::Base
  attr_accessible :tag, :title, :body, :status, :mode

  has_paper_trail
  enum status: [:unpublished, :published]
  enum mode: [:plain_markdown, :cards, :cards_with_shortcuts]

end
