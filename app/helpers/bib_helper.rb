module BibHelper
  def linkify_record(source, holding)
    case source.source_type
    when 'aleph', 'primo', 'idea'
      url = source.item_pattern.sub('__ID__', holding.source_id.strip)
    when 'hebrewbooks'
      url = holding.source_id.strip
    when 'googlebooks'
      url =  "https://books.google.co.il/books?id=#{holding.source_id.strip}"
    end
    return link_to holding.source_id, url
  end
  def pubs_to_markup(pubs)
    ret = ''
    pubs.each do |pub|
      ret += escape_javascript("<tr><td>#{pub.title}</td><td>#{pub.author_line}</td><td>#{pub.publisher_line}</td><td>#{pub.pub_year}</td><td>#{pub.language}</td><td>#{pub.notes.nil? ? '' : pub.notes.sub("\n", "<br />".html_safe)}</td><td>#{pub.holdings.map{|h| linkify_record(pub.context, h)}.join(';')}</td></tr>");
    end
    return ret
  end
end
