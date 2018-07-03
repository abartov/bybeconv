module BibHelper
  def linkify_record(source, source_id)
    return link_to source_id, url_for_record(source, source_id)
  end
end
