class StaticPage < ApplicationRecord
  # attr_accessible :tag, :title, :body, :status, :mode, :ltr

  has_paper_trail
  enum status: [:unpublished, :published]
  enum mode: [:plain_markdown, :cards, :cards_with_shortcuts]

  def english?
    buf = self.body[0..(self.body.length > 1000 ? 1000 : -1)]
    hebcount = 0
    buf.each_codepoint{|cp| hebcount += 1 if buf.is_hebrew_codepoint_utf8(cp)}
    if hebcount > buf.length / 2
      return false
    else
      return true
    end
  end

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
