class StaticPage < ActiveRecord::Base
  attr_accessible :tag, :title, :body, :status, :mode

  has_paper_trail
  enum status: [:unpublished, :published]
  enum mode: [:plain_markdown, :cards, :cards_with_shortcuts]

  def prepare_markdown
    markdown = MultiMarkdown.new(self.body).to_html.force_encoding('UTF-8')
    unless self.mode == 'plain_markdown' # then all paragraphs should be in cards
      parts = markdown.split("<h2")
      newbuf = parts[0]
      parts[1..-1].each {|p|
        newbuf += '<div class="card"><h2' + p + '</div>'
      }
      markdown = newbuf
    end
    return markdown
  end
end
