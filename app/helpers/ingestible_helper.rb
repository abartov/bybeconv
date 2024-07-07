module IngestibleHelper
  def title_from_prospective_volume_id(prospective_volume_id)
    return nil if prospective_volume_id.nil?
    if(prospective_volume_id[0] == 'P')
      pub = Publication.find(prospective_volume_id[1..-1])
      return "#{pub.authority.name} – #{pub.title} (#{t(:new)}!)"
    else
      return Collection.find(prospective_volume_id[1..-1]).title_and_authors
    end
  end
end
