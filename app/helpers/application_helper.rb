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
  def options_for_shelves
    # TODO: once user system is in place, add user's custom shelves
    return '<option>'+t(:want_to_read)+'</option><option>'+t(:currently_reading)+'</option><option>'+t(:have_read)+'</option>'
  end
  def textify_genre(genre)
    return I18n.t(:unknown) if genre.nil?
    return I18n.t(genre)
  end
  def textify_lang(iso)
    return I18n.t(:unknown) if iso.nil? or iso.empty?
    case iso
    when 'he'
      return t(:hebrew)
    when 'en'
      return t(:english)
    when 'de'
      return t(:german)
    when 'ru'
      return t(:russian)
    when 'yi'
      return t(:yiddish)
    when 'pl'
      return t(:polish)
    when 'fr'
      return t(:french)
    when 'ar'
      return t(:arabic)
    when 'el'
      return t(:greek)
    when 'la'
      return t(:latin)
    when 'grc'
      return t(:ancient_greek)
    else
      return t(:unknown)
    end
  end

  def textify_copyright_status(copyrighted)
    copyrighted ? t(:by_permission) : t(:public_domain)
  end

  def sitenotice
    return ''
  end

end
