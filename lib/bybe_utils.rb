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

module BybeUtils
  def make_epub_from_single_html(html, manifestation)
    book = GEPUB::Book.new
    book.set_main_id('http://benyehuda.org/read/'+manifestation.id.to_s, 'BookID', 'URL')
    book.language = 'he'
    title = manifestation.title+' מאת '+manifestation.author_string
    book.add_title(title, nil, GEPUB::TITLE_TYPE::MAIN)
    book.add_creator(manifestation.author_string)
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
    gc.text(0,150,"פרי עמלם של מתנדבי פרויקט בן-יהודה".reverse.center(50))
    gc.pointsize(20)
    gc.text(0,250,Date.today.to_s+"מעודכן לתאריך: ".reverse.center(50))
    gc.draw(canvas)
    cover_file = Tempfile.new(['tmp_cover_'+manifestation.id.to_s,'.png'], 'tmp/')
    canvas.write(cover_file.path)
    book.add_item('cover.jpg',cover_file.path).cover_image
    book.ordered {
      buf = '<head><meta charset="UTF-8"><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body dir="rtl" align="center"><h1>'+title+'</h1><p/><p/><h3>פרי עמלם של מתנדבי</h3><p/><h2>פרויקט בן-יהודה</h2><p/><h3><a href="http://benyehuda.org/blog/%D7%A8%D7%95%D7%A6%D7%99%D7%9D-%D7%9C%D7%A2%D7%96%D7%95%D7%A8">(רוצים לעזור?)</a></h3><p/>מעודכן לתאריך: '+Date.today.to_s+'</body>'
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
    return author_surname_and_initials(manifestation.author_string)+'. ('+citation_date(manifestation.expressions[0].date)+'). <strong>'+manifestation.title+'</strong>'+'. [גרסה אלקטרונית]. פרויקט בן-יהודה. נדלה בתאריך '+Date.today.to_s+". #{request.original_url}"
  end
  def mla_citation(manifestation)
    return author_surname_and_firstname(manifestation.author_string)+". \"#{manifestation.title}\". <u>פרויקט בן-יהודה</u>. #{citation_date(manifestation.expressions[0].date)}. #{Date.today.to_s}. &lt;#{request.original_url}&gt;"
  end
  def asa_citation(manifestation)
    return author_surname_and_firstname(manifestation.author_string)+'. '+citation_date(manifestation.expressions[0].date)+". \"#{manifestation.title}\". <strong>פרויקט בן-יהודה</strong>. אוחזר בתאריך #{Date.today.to_s}. (#{request.original_url})"
  end

  def identify_genre_by_heading(text)
    case text
    when /שירה/
      return 'poetry'
    when /פרוזה/
      return 'prose'
    when /מסות/
      return 'article'
    when /זכרונות/
      return 'memoir'
    when /תרגום/, /יצירות מתורגמות/
      return 'translations'
    when /מחזות/, /דרמה/
      return 'drama'
    when /משלים/
      return 'fables'
    when /מכתבים/, /אגרות/
      return 'letters'
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
          ret_a << "<a name='#{genre}_g'></a>\n"
        end
        ret_a << l
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
        anchor_name = $2.gsub('[','\[').gsub(']','\]')
        if item[0] == 'ה' # linking to a legacy HtmlFile
          h = HtmlFile.find(item[1..-1].to_i)
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

  def get_total_works
    return Manifestation.cached_count
  end

  def get_total_authors
    return Person.cached_toc_count
  end

  def get_total_headwords
    return 2341 # TODO: un-hardcode
  end

  def get_genres
    return ['poetry', 'prose', 'drama', 'fables','article', 'memoir', 'letters', 'reference', 'lexicon'] # translations and icon-font refer to these keys!
  end

  def right_side_genres
    return ['poetry', 'prose', 'drama', 'fables','article', 'memoir', 'letters', 'reference'] # translations and icon-font refer to these keys!
  end

  def get_langs
    return ['he','en','fr','de','ru','yi','pl','ar','el','la','grc','hu','cs','da','no','sv','nl','it','pt']
  end

  def get_genres_by_row(row) # just one row at a time
    return case row
      when 1 then ['poetry', 'prose', 'drama', 'fables'].reverse # TODO: switch to Bootstrap-RTL?
      when 2 then ['article', 'memoir', 'letters', 'reference'].reverse
      when 3 then ['surprise', 'lexicon','translations'].reverse
    end
  end
end
