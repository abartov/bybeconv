# frozen_string_literal: true

# Converts markdown to HTML
class MarkdownToHtml < ApplicationService
  def call(markdown)
    return '' if markdown.blank?

    MultiMarkdown.new(markdown).to_html.force_encoding('UTF-8')
                 .gsub(%r{<figcaption>.*?</figcaption>}, '') # remove MMD's automatic figcaptions
  end
end
