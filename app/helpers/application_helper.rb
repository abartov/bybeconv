module ApplicationHelper
  def u8(s)
    return s if s.nil?
    s.force_encoding('UTF-8')
  end

  def url_tag(u)
    return '' if u.blank?
    return 'ויקיפדיה' if u =~ /https?:\/\/he.wikipedia.org/
    return 'לקסיקון' if u =~ /https?:\/\/library.osu.edu\/projects\/hebrew-lexicon/
    return 'VIAF' if u =~ /https?:\/\/viaf.org\/viaf\//
    'אחר'
  end

  def viaf_json_to_html(json)
    ret = '<ul>'
    json.each do |j|
      ret += "<li>#{j[0]} (VIAF: #{j[1]})\n"
    end
    ret += '</ul>'
  end
  def absolute_url_from_urlpart(u)
    return AppConstants.base_dir+u
  end
  def textify_external_link_type(linktype)
    return I18n.t(linktype)
  end
end
