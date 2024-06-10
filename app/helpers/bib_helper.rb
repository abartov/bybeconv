module BibHelper
  @@bib_sources = {}
  def linkify_record(source, source_id)
    return link_to(source.title, url_for_record(source, source_id))
  end
  def textify_bib_source(id)
    BibSource.all.each{|x| @@bib_sources[x.id] = x.title} if @@bib_sources.empty?
    @@bib_sources[id]
  end
end
