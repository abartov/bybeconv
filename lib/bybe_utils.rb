require 'json' # for VIAF AutoSuggest
require 'rdf'
require 'rdf/vocab'
require 'hebrew'
require 'htmlentities'
require 'gepub'
require 'rmagick'

include ActionView::Helpers::SanitizeHelper

# temporary constants until I figure out what changed in RDF.rb's RDF::Vocab::SKOS
SKOS_PREFLABEL = "http://www.w3.org/2004/02/skos/core#prefLabel"
SKOS_ALTLABEL = "http://www.w3.org/2004/02/skos/core#altLabel"
HEBMONTHS = { 'ניסן' => 1, 'אייר' => 2, 'סיון' => 3, 'סיוון' => 3, 'תמוז' => 4, 'אב' => 5, 'אלול' => 6, 'תשרי' => 7, 'חשון' => 8, 'חשוון' => 8, 'כסלו' => 9, 'טבת' => 10, 'שבט' => 11, 'אדר' => 12 } # handling Adar Bet is a special pain we're knowingly ignoring
GREGMONTHS = {'ינואר' => 1,'פברואר' => 2,'מרץ' => 3,'מרס' => 3,'מארס' => 3,'אפריל' => 4,'מאי' => 5,'יוני' => 6,'יולי' => 7,'אוגוסט' => 8,'אבגוסט' => 8,'ספטמבר' => 9,'אוקטובר' => 10,'נובמבר' => 11, 'דצמבר' => 12}
HEB_LETTER_VALUE = {'א' => 1, 'ב' => 2, 'ג' => 3, 'ד' => 4, 'ה' => 5, 'ו' => 6, 'ז' => 7, 'ח' => 8, 'ט' => 9, 'י' => 10, 'כ' => 20, 'ך' => 20, 'ל' => 30, 'מ' => 40, 'ם' => 40, 'נ' => 50, 'ן' => 50, 'ס' => 60, 'ע' => 70, 'פ' => 80, 'ף' => 80, 'צ' => 90, 'ץ' => 90, 'ק' => 100, 'ר' => 200, 'ש' => 300, 'ת' => 400}

module BybeUtils
  def make_epub_from_single_html(html, manifestation, author_string)
    book = GEPUB::Book.new
    book.primary_identifier('http://benyehuda.org/read/'+manifestation.id.to_s, 'BookID', 'URL')
    book.language = 'he'
    title = manifestation.title+' מאת '+author_string
    book.add_title(title, nil, GEPUB::TITLE_TYPE::MAIN)
    book.add_creator(author_string)
    book.page_progression_direction = 'rtl' # Hebrew! :)
    # make cover image
    canvas = Magick::Image.new(1200, 800){self.background_color = 'white'}
    gc = Magick::Draw.new
    gc.gravity = Magick::CenterGravity
    gc.pointsize(50)
    gc.font('David CLM')
    gc.text(0,0,title.reverse.center(50))
    gc.draw(canvas)
    gc.pointsize(30)
    gc.text(0,150,"פרי עמלם של מתנדבי פרויקט בן־יהודה".reverse.center(50))
    gc.pointsize(20)
    gc.text(0,250,Date.today.to_s+"מעודכן לתאריך: ".reverse.center(50))
    gc.draw(canvas)
    cover_file = Tempfile.new(['tmp_cover_'+manifestation.id.to_s,'.png'], 'tmp/')
    canvas.write(cover_file.path)
    book.add_item('cover.jpg',cover_file.path).cover_image
    book.ordered {
      buf = '<head><meta charset="UTF-8"><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body dir="rtl" align="center"><h1>'+title+'</h1><p/><p/><h3>פרי עמלם של מתנדבי</h3><p/><h2>פרויקט בן־יהודה</h2><p/><h3><a href="https://benyehuda.org/page/volunteer">(רוצים לעזור?)</a></h3><p/>מעודכן לתאריך: '+Date.today.to_s+'</body>'
      book.add_item('0_title.html').add_content(StringIO.new(buf))
      book.add_item('1_text.html').add_content(StringIO.new(html)).toc_text(title)
    }
    fname = cover_file.path+'.epub'
    book.generate_epub(fname)
    cover_file.close
    return fname
  end

  # return a hash like {:total => total_number_of_non_tags_characters, :nikkud => total_number_of_nikkud_characters, :ratio => :nikkud/:total }
  def count_nikkud(text)
    info = { total: 0, nikkud: 0, ratio: nil }
    ignore = false
    text.each_char do |c|
      if c == '<'
        ignore = true
      elsif c == '>'
        ignore = false
        next
      end
      unless ignore or c.match /\s/ # ignore tags and whitespace
        info[:nikkud] += 1 if text.is_nikkud(c)
        info[:total] += 1
      end
    end
    if text.length < 200 and text.length > 50
      info[:total] -= 35 # rough compensation for text of index and main page links, to mitigate ratio problem for very short texts
    end
    info[:ratio] = info[:nikkud].to_f / info[:total]
#    puts "DBG: total #{info[:total]} - nikkud #{info[:nikkud]} - ratio #{info[:ratio]}"
    return info
  end

  # new definition of full nikkud: no more than two (or one, if under three words) of the words lack nikkud
  def is_full_nikkud(text)
    a = text.split /\b/ # split at word boundaries
    b = a.select{|x| x =~ /[^\s,?!.;'`"\-–]/} # leave only actual words
    count = 0
    b.each{|word| count += 1 if word.any_nikkud?}
    target = b.length < 3 ? 1 : b.length - 2
    return (count < target ? false : true)
  end

  def parse_gregorian(str)
    return Date.new($3.to_i, $2.to_i, $1.to_i) if(str =~ /(\d\d?)[-\/\.](\d\d?)[-\/\.](\d+)/) # try to match numeric date
    # perhaps there's a date with spaces and a Gregorian month name in Hebrew
    GREGMONTHS.keys.each do |m|
      unless str.match(/ב?#{m}\s+/).nil?
        month = GREGMONTHS[m]
        pre = $`
        year = $'.match(/\d+/).to_s.to_i
        day = (pre.match(/\d+/)) ? $&.to_i : 15 # mid-month by default
        return Date.new(year, month, day)
      end
    end
    # we couldn't identify a month; try to use just the year
    str.match(/\d+/)
    return Date.new($&.to_i, 7, 1) # mid-year by default
  end

  def parse_hebrew_year(str)
    i = 0
    s = str
    if str[0] == 'ה'
      i += 5000
      s = str[1..-1]
    elsif str[0] == 'ד'
      i += 4000
      s = str[1..-1]
    end
    s.each_char{|c| i += HEB_LETTER_VALUE[c]}
    i += 5000 if i < 1000 and i != 0 # assume current Hebrew millennium if no other one is specified
    return i
  end

  def parse_hebrew_day(str)
    s = str.tr("\'\"",'') # ignore quotes
    s = s[0..1] if s.length > 2 # ignore prefixes like ב
    s = s[0] unless s.length == 1 || ['ט','י','כ','ל'].include?(s[0]) # only possible first-letters of a two-character hebrew date day
    i = 0
    s.each_char{|c| i += HEB_LETTER_VALUE[c]}
    return i
  end

  def parse_hebrew_date(str)
    HEBMONTHS.keys.each do |m|
      unless str.match(/ב?\S*#{m}\s+/).nil?
        month = HEBMONTHS[m]
        pre = $`
        rpos = $`.rindex(' ')
        pre = $`[0..rpos - 1] unless rpos.nil? # move back to last space (because month may have contained a prefix, like מרחשוון)
        rpos = pre.rindex(' ')
        pre = pre[rpos + 1..-1] unless pre.empty? or rpos.nil?
        year = $'.match(/\S+\"\S/).to_s.strip.tr('\"\'','')
        if pre.empty?
          day = 15
        else
          day = parse_hebrew_day(pre) || 15 # mid-month by default
        end
        hyear = parse_hebrew_year(year)
        unless hyear.nil? || hyear == 0
          hd = Hebruby::HebrewDate.new(day, month, hyear)
          return hd.julian_date
        else
          return nil
        end
      end
    end
    return nil
  end

  def normalize_date(str)
    return nil if str.nil? or str.empty?
    # first look for digits
    return parse_gregorian(str) if str.match(/\d+/)
    # parse hebrew date
    if str.any_hebrew?
      return parse_hebrew_date(str)
    else
      return nil
    end
  end

  # just return a boolean if the buffer is "full" nikkud
  def full_nikkud(text)
    info = count_nikkud(text)
    false || (info[:total] > 1000 and info[:ratio] > 0.5) || (info[:total] <= 1000 and info[:ratio] > 0.3)
  end

  # retrieve author name for (relative) directory name d, using provided hash known_authors to cache results
  def author_name_from_dir(d, known_authors)
    if known_authors[d].nil?
      thedir = HtmlDir.where(path: d)
      if thedir.nil? or thedir.empty?
        thedir = HtmlDir.new(path: d, author: "__edit__#{d}")
        thedir.save! # to be filled later
      else
        thedir = thedir[0]
      end
      known_authors[d] = thedir.author.force_encoding('utf-8')
    end
    known_authors[d]
  end

  # attempt to match a string against Person records
  def match_person(str)
    matches = Person.where(name: str)
    return matches unless matches.nil?
    lastname = str.split(' ')[-1]
    return Person.where("name LIKE ?", "%#{lastname}%")
  end

  def guess_authors_viaf(author_string)
    # Try VIAF first
    viaf = Net::HTTP.new('www.viaf.org')
    viaf.start unless viaf.started?
    viaf_result = JSON.parse(viaf.get("/viaf/AutoSuggest?query=#{URI.escape(author_string)}").body)
    logger.debug("viaf_result: #{viaf_result.to_s}")
    logger.debug("viaf_result['result']: #{viaf_result['result'].to_s}")
    if viaf_result['result'].nil?
      viaf_result = JSON.parse(viaf.get("/viaf/AutoSuggest?query=#{URI.escape(author_string.split(/[, ]/)[0])}").body) # try again with just the first word
    end
    return nil if viaf_result['result'].nil? # give up
    viaf_items = viaf_result['result'].map { |h| [h['term'], h['viafid']] }
    logger.info("#{viaf_items.length} results from VIAF for #{author_string}")
    viaf_items

    # Try NLI
    # ZOOM::Connection.open('aleph.nli.org.il', 9991) do |conn|
    #  conn.database_name = 'NNL01'
    #  conn.preferred_record_syntax = 'XML'
    #  #conn.preferred_record_syntax = 'USMARC'
    #  rset = conn.search("@attr 1=1003 @attr 2=3 @attr 4=1 @attr 5=100 \"#{author_string}\"")
    #  p rset[0]
    # end
  end

  def textify_lang(iso)
    return I18n.t(:unknown) if iso.nil? or iso.empty?
    case iso
    when 'he'
      return I18n.t(:hebrew)
    when 'en'
      return I18n.t(:english)
    when 'de'
      return I18n.t(:german)
    when 'ru'
      return I18n.t(:russian)
    when 'es'
      return I18n.t(:spanish)
    when 'yi'
      return I18n.t(:yiddish)
    when 'arc'
      return I18n.t(:aramaic)
    when 'zh'
      return I18n.t(:chinese)
    when 'pl'
      return I18n.t(:polish)
    when 'fr'
      return I18n.t(:french)
    when 'ar'
      return I18n.t(:arabic)
    when 'el'
      return I18n.t(:greek)
    when 'la'
      return I18n.t(:latin)
    when 'it'
      return I18n.t(:italian)
    when 'grc'
      return I18n.t(:ancient_greek)
    when 'hu'
      return I18n.t(:hungarian)
    when 'cs'
      return I18n.t(:czech)
    when 'da'
      return I18n.t(:danish)
    when 'no'
      return I18n.t(:norwegian)
    when 'nl'
      return I18n.t(:dutch)
    when 'pt'
      return I18n.t(:portuguese)
    when 'fi'
      return I18n.t(:finnish)
    when 'is'
      return I18n.t(:icelandic)
    when 'fa'
      return I18n.t(:persian)
    when 'sv'
      return I18n.t(:swedish)
    when 'lad'
      return I18n.t(:ladino)
    else
      return I18n.t(:unknown)
    end
  end

  # returns an up-to-maxchars-character snippet and the rest of the buffer
  def snippet(buf, maxchars)
    return [buf,''] if buf.length < maxchars
    tmp = buf[0..maxchars]
    pos = tmp.rindex(' ')
    ret = tmp[0..pos] # don't break up mid-word
    return [ret, tmp[pos..-1]+' '+buf[maxchars..-1]]
  end

  def raw_viaf_xml_by_viaf_id(viaf_id)
    RDF::Graph.load("http://viaf.org/viaf/#{viaf_id}/rdf.xml")
  end

  def rdf_collect(graph, uri)
    ret = []
    query = RDF::Query.new do
      pattern [:labels, uri, :datum]
    end
    query.execute(graph) do |entity|
      ret << entity.datum.to_s if entity.datum.to_s.any_hebrew? # we only care about Hebrew labels
    end
    ret
  end

  def viaf_record_by_id(viaf_id)
    graph = raw_viaf_xml_by_viaf_id(viaf_id)
    query = RDF::Query.new(person: {
                             RDF::URI('http://schema.org/birthDate') => :birthDate,
                             RDF::URI('http://schema.org/deathDate') => :deathDate
                           })
    ret = {}
    query.execute(graph) do |entity|
      ret['birthDate'] = entity.birthDate.to_s unless entity.birthDate.nil?
      ret['deathDate'] = entity.deathDate.to_s unless entity.deathDate.nil?
    end
    ret['labels'] = []
    ret['labels'] += rdf_collect(graph, RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel'))
    ret['labels'] += rdf_collect(graph, RDF::URI(SKOS_PREFLABEL))
    if ret['labels'].empty? # if there are no Hebrew prefLabels, try the altLabels
      ret['labels'] += rdf_collect(graph, RDF::URI(SKOS_ALTLABEL))
    end

    ret
  end

  def fix_encoding(buf)
    newbuf = buf.force_encoding('windows-1255')
        ENCODING_SUBSTS.each { |s|
          newbuf.gsub!(s[:from].force_encoding('windows-1255'), s[:to])
        }
    return newbuf
  end
  def is_blacklisted_ip(ip)
    # check posting IP against HTTP:BL
    unless AppConstants.project_honeypot_api_key.nil?
      listing = ProjectHoneypot.lookup(AppConstants.project_honeypot_api_key, ip)
      if listing.comment_spammer? or listing.suspicious? # silently ignore spam submissions
        logger.info "SPAM IP identified by HTTP:BL lookup.  Ignoring form submission."
        return true
      end
    end
    return false
  end
  def client_ip
    #logger.debug "client_ip - request.env dump follows\n#{request.env.to_s}"
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end
  def remove_payload(buf)
    m = buf.match(/<!-- begin BY head -->/)
    return buf if m.nil? # though, seriously?
    tmpbuf = $`
    m = buf.match(/<!-- end BY head -->/)
    tmpbuf += $'
    m = tmpbuf.match(/<!-- begin BY body -->/)
    newbuf = $`
    m = tmpbuf.match(/<!-- end BY body -->/)
    newbuf += $'
    return newbuf
  end
  def remove_toc_links(buf)
    return buf.gsub(/<a\s+?href="index.html">.*?<\/a>/mi, '').gsub(/<a\s+?href="\/">.*?<\/a>/mi,'').gsub(/<a\s+?href="http:\/\/benyehuda.org\/"/mi,'')
  end
  def remove_prose_table(buf)
    buf =~ /<table.*? width="70%".*?>.*?<td.*?>(.*)<\/td>.*?<\/table>/im # if prose table exists, grab its contents
    return buf if $1 == nil
    return $` + $1 + $'
  end
  def html2txt(buf)
    coder = HTMLEntities.new
    return strip_tags(coder.decode(buf)).gsub(/<!\[.*?\]>/,'')
  end
  def author_surname_and_initials(author_string) # TODO: support multiple authors
    parts = author_string.split(' ')
    surname = parts.pop
    initials = ''
    parts.each {|p| initials += p[0]}
    if initials.length == 1
      initials += "'"
    elsif initials.length == 0
      return surname
    else
      initials = initials[0..-2] + '"' + initials[-1]
    end
    return surname + ', ' + initials
  end
  def author_surname_and_firstname(author_string) # TODO: support multiple authors
    parts = author_string.split(' ')
    surname = parts.pop
    return surname+', '+parts.join(' ')
  end
  def citation_date(date_str)
    return I18n.t(:no_date) if date_str.nil?
    if date_str =~ /\d\d\d+/
      return $&
    else
      return date_str
    end
  end
  def apa_citation(manifestation)
    return author_surname_and_initials(manifestation.author_string)+'. ('+citation_date(manifestation.expressions[0].date)+'). <strong>'+manifestation.title+'</strong>'+'. [גרסה אלקטרונית]. פרויקט בן־יהודה. נדלה בתאריך '+Date.today.to_s+". #{request.original_url}"
  end
  def mla_citation(manifestation)
    return author_surname_and_firstname(manifestation.author_string)+". \"#{manifestation.title}\". <u>פרויקט בן־יהודה</u>. #{citation_date(manifestation.expressions[0].date)}. #{Date.today.to_s}. &lt;#{request.original_url}&gt;"
  end
  def asa_citation(manifestation)
    return author_surname_and_firstname(manifestation.author_string)+'. '+citation_date(manifestation.expressions[0].date)+". \"#{manifestation.title}\". <strong>פרויקט בן־יהודה</strong>. אוחזר בתאריך #{Date.today.to_s}. (#{request.original_url})"
  end

  def identify_genre_by_heading(text)
    case text
    when /שירה/
      return 'poetry'
    when /פרוזה/
      return 'prose'
    when /מסות/, /מאמרים/
      return 'article'
    when /זכרונות/, /זכרונות ויומנים/
      return 'memoir'
    when /תרגום/, /יצירות מתורגמות/
      return 'translations'
    when /מחזות/, /דרמה/
      return 'drama'
    when /משלים/
      return 'fables'
    when /מכתבים/, /אגרות/
      return 'letters'
    when /עיון/
      return 'reference'
    when /מילונים/, /לקסיקונים/
      return 'lexicon'
    else
      return nil
    end
  end

  def divide_by_genre(buf)
    ret_parts = []
    ret_a = []
    genres = []
    part = ''
    lines = buf.lines
    lines.each{|l|
      if l =~ /^##[^#]/
        genre = identify_genre_by_heading($')
        unless genre.nil?
          unless part.empty? # if not first genre
            genres << part
            ret_parts << [part, ret_a.join]
            ret_a = []
          end
          part = genre
          ret_a << "<a name='#{genre}_g' id='#{genre}_g' class='g_anch'>&nbsp;</a>\n"
        else
          ret_a << l # deliberately don't add the genre name - provided by UI
        end
      else
        ret_a << l
      end
    }
    ret_parts << [part, ret_a.join] # add last batch
    genres << part
    ret_parts.unshift(genres)
    return ret_parts
  end

  def toc_links_to_markdown_links(buf)
    ret = ''
    until buf.empty?
      m = buf.match /&&&\s*פריט: (\S\d+)\s*&&&\s*כותרת: (.*?)\s*&&&/ # tolerate whitespace; this will be edited manually
      if m.nil?
        ret += buf
        buf = ''
      else
        ret += $`
        addition = $& # by default
        buf = $'
        item = $1
        anchor_name = $2.gsub('[','\[').gsub(']','\]').gsub('"','\"').gsub("'", "\\\\'")
        if item[0] == 'ה' # linking to a legacy HtmlFile
          h = HtmlFile.find_by(id: item[1..-1].to_i)
          unless h.nil?
            addition = "[#{anchor_name}](#{h.url})"
          end
        else # manifestation
          begin
            mft = Manifestation.find(item[1..-1].to_i)
            unless mft.nil?
              addition = "[#{anchor_name}](#{url_for(controller: :manifestation, action: :read, id: mft.id)})"
            end
          rescue
            logger.info("Manifestation not found: #{item[1..-1].to_i}!")
          end
        end
        ret += addition
      end
    end
    return ret
  end

  def work_count_by_period(p)
    return Expression.cached_work_count_by_period(p)
  end

  def get_total_works
    return Manifestation.cached_count
  end

  def get_total_authors
    return Person.cached_toc_count
  end

  def get_total_headwords
    Rails.cache.fetch("total_headwords", expires_in: 24.hours) do # memoize
      DictionaryEntry.where("defhead is not null").count
    end
  end

  ## hardcoded
  def get_periods
    return ['ancient','medieval','enlightenment','revival', 'modern']
  end

  def get_genres
    return ['poetry', 'prose', 'drama', 'fables','article', 'memoir', 'letters', 'reference', 'lexicon'] # translations and icon-font refer to these keys!
  end

  def right_side_genres
    return ['poetry', 'prose', 'drama', 'fables','article', 'memoir', 'letters', 'reference'] # translations and icon-font refer to these keys!
  end

  ## hardcoded according to graphic design
  def glyph_for_genre(genre)
    case genre
      when 'poetry'
        return 't'
      when 'prose'
        return 'l'
      when 'drama'
        return 'k'
      when 'fables'
        return 'E'
      when 'article'
        return 'a'
      when 'memoir'
        return 'j'
      when 'letters'
        return 'w'
      when 'reference'
        return 'v'
      when 'lexicon'
        return 'f'
      when 'translations'
        return 's'
    end
    return '' # fallback
  end

  def get_langs
    return ['he','en','fr','de','ru','yi','pl','ar','el','la','grc','hu','cs','da','no','sv','nl','it','pt','fa','fi','is','es', 'arc', 'lad', 'zh' ,'unk']
  end

  def get_genres_by_row(row) # just one row at a time
    return case row
      when 1 then ['poetry', 'prose', 'drama', 'fables']
      when 2 then ['article', 'memoir', 'letters', 'reference']
      when 3 then ['surprise', 'lexicon','translations']
    end
  end
  def url_for_record(source, source_id)
    case source.source_type
    when 'aleph', 'primo', 'idea'
      url = source.item_pattern.sub('__ID__', source_id.strip)
    when 'hebrewbooks'
      url = source_id.strip
    when 'nli_api'
      url = source_id.sub('/en/','/he/')
    when 'googlebooks'
      url =  "https://books.google.co.il/books?id=#{source_id.strip}"
    end
    return url
  end
  def is_legacy_url(url)
    url = '/' + url if url[0] != '/' # prepend slash if necessary
    h = HtmlFile.find_by_url(url)
    # also treat /{author} or /{author}/ or /{author}/index.html as legacy urls
    if h.nil?
      if url =~ /\/([^\/]*)\/?(index\.html)?/
        h = HtmlDir.find_by_path($1)
      end
    end
    return h != nil
  end

  def redspan(s)
    return '<span style="color:red; font-size: 250%">'+s+'</span>'
  end

  def highlight_suspicious_markdown(buf)
    buf.gsub('**', redspan('**')).gsub('| ', redspan('| ')).gsub('##', redspan('##'))
  end
  def replace_with_redirect(m_id_to_delete, m_id_to_redirect_to)
    m = Manifestation.find(m_id_to_delete)
    h = m.html_files[0]
    ats = AnthologyText.where(manifestation_id: m_id_to_delete)
    ats.each do |at|
      begin
        at.manifestation_id = m_id_to_redirect_to
        at.save!
      rescue
        at.destroy
      end
    end
    h.manifestations[0].manual_delete
    h.manifestation_ids << m_id_to_redirect_to
    h.save
  end
  def pub_title_for_comparison(s)
    ret = ''
    if s['/'].nil?
      ret = s[0..[10,s.length].min]
    else
      ret = s[0..[10,s.index('/')-1].min]
    end
    return ret.strip
  end
  def clean_up_spaces(buf)
    newbuf = ''
    had_any_content = false
    add_space = false
    buf.each_char do |ch|
      is_space = is_codepoint_space(ch.codepoints[0])
      is_bracket = ['[',']'].include?(ch)
      next if is_space and not had_any_content # skip leading whitespace
      if is_space
        add_space = true
      else
        if add_space and not is_bracket
          newbuf += ' ' # add a single space
          add_space = false
        end
        had_any_content = true unless is_bracket
        newbuf += ch
      end
    end
    return newbuf
  end
  
  def is_codepoint_space(cp)
    [9, 10, 11, 12, 13, 32, 133, 160, 5760, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8232, 8233, 8239, 8287, 12288].include?(cp)
  end
end
