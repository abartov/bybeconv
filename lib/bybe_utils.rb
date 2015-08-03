require 'json' # for VIAF AutoSuggest
require 'linkeddata'
require 'hebrew'

module BybeUtils
  # return a hash like {:total => total_number_of_non_tags_characters, :nikkud => total_number_of_nikkud_characters, :ratio => :nikkud/:total }
  def count_nikkud(text)
    info = { total: 0, nikkud: 0, ratio: nil }
    ignore = false
    text.each_char do|c|
      if c == '<'
        ignore = true
      elsif c == '>'
        ignore = false
        next
      end
      unless ignore || c.match(/\s/) # ignore tags and whitespace
        info[:nikkud] += 1 if ["\u05B0", "\u05B1", "\u05B2", "\u05B3", "\u05B4", "\u05B5", "\u05B6", "\u05B7", "\u05B8", "\u05B9", "\u05BB", "\u05BC", "\u05C1", "\u05C2"].include? c
        info[:total] += 1
      end
    end
    info[:total] -= 35 # rough compensation for text of index and main page links, to mitigate ratio problem for very short texts
    info[:ratio] = info[:nikkud].to_f / info[:total]
    puts "DBG: total #{info[:total]} - nikkud #{info[:nikkud]} - ratio #{info[:ratio]}"
    info
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

  def guess_authors_viaf(author_string)
    # Try VIAF first
    viaf = Net::HTTP.new('www.viaf.org')
    viaf.start unless viaf.started?
    viaf_result = JSON.parse(viaf.get("/viaf/AutoSuggest?query=#{URI.escape(author_string)}").body)
    return nil if viaf_result['result'].nil?
    viaf_items = viaf_result['result'].map { |h| [h['term'], h['viafid']] }
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
    ret['labels'] += rdf_collect(graph, RDF::SKOS.prefLabel)
    if ret['labels'].empty? # if there are no Hebrew prefLabels, try the altLabels
      ret['labels'] += rdf_collect(graph, RDF::SKOS.altLabel)
    end

    ret
  end
end
