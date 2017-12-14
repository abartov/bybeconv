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

  def safe_options_for_select(container, selected = nil)
    ret = ''
    container.each_pair do |heading, lineno|
      ret += "<option value='#{lineno}' #{selected == heading ? 'selected=\'selected\'' : ''}>#{heading}</option>"
    end
    return ret.html_safe
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
    return I18n.t(:unknown) if genre.nil? or genre.empty?
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
    when 'it'
      return t(:italian)
    when 'grc'
      return t(:ancient_greek)
    when 'hu'
      return t(:hungarian)
    when 'cs'
      return t(:czech)
    when 'da'
      return t(:danish)
    when 'no'
      return t(:norwegian)
    when 'nl'
      return t(:dutch)
    when 'pt'
      return t(:portuguese)
    when 'sv'
      return t(:swedish)
    else
      return t(:unknown)
    end
  end

  def textify_copyright_status(copyrighted)
    copyrighted ? t(:by_permission) : t(:public_domain)
  end

  def textify_boolean(bool)
    bool ? t(:yes) : t(:no)
  end

  def textify_nikkud(nik)
    return I18n.t(:unknown) if nik.nil? or nik.empty?
    return I18n.t(nik)
  end

  def textify_htmlfile_status(st)
    return I18n.t(:unknown) if st.nil? or st.empty?
    case st
    when 'Unknown'
      return t(:unknown)
    when 'BadUTF8'
      return t(:bad_enc)
    when 'FileError'
      return t(:file_err)
    when 'Parsed'
      return t(:parsed)
    when 'Accepted'
      return t(:accepted)
    when 'Analyzed'
      return t(:analyzed)
    when 'Published'
      return t(:published)
    when 'Manual'
      return t(:manual)
    else
      return t(:unknown)
    end
  end

  def textify_toc_status(st)
    return I18n.t(:unknown) if st.nil? or st.empty?
    return I18n.t(st)
  end

  def sitenotice
    return '' # TODO: implement
  end

  def linkify_people(people)
    return '' if people.nil? or people.empty?
    ret = ''
    i = 0
    people.each {|p|
      ret += ', 'if i > 0
      ret += link_to p.name, authors_show_path(id: p.id)
      i += 1
    }
    return ret
  end

end
