module ApplicationHelper
  def u8(s)
    return s if s.nil?
    return s.force_encoding('UTF-8')
  end
  def url_tag(u)
    return '' if u.blank?
    return 'ויקיפדיה' if u =~ /https?:\/\/he.wikipedia.org/
    return 'לקסיקון' if u =~ /https?:\/\/library.osu.edu\/projects\/hebrew-lexicon/ 
    return 'VIAF' if u =~ /https?:\/\/viaf.org\/viaf\//
    return 'אחר' 
  end
  def absolute_url_from_urlpart(u)
    return AppConstants.base_dir+u
  end
end
