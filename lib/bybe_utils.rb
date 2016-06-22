require 'json' # for VIAF AutoSuggest
require 'rdf'
require 'rdf/vocab'
require 'hebrew'

# temporary constants until I figure out what changed in RDF.rb's RDF::Vocab::SKOS
SKOS_PREFLABEL = "http://www.w3.org/2004/02/skos/core#prefLabel"
SKOS_ALTLABEL = "http://www.w3.org/2004/02/skos/core#altLabel"

module BybeUtils
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
      thedir = HtmlDir.find_by_path(d)
      if thedir.nil?
        thedir = HtmlDir.new(path: d, author: "__edit__#{d}")
        thedir.save! # to be filled later
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
    return nil if viaf_result['result'].nil?
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
end
