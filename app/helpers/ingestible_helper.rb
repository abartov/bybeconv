module IngestibleHelper
  def title_from_prospective_volume_id(prospective_volume_id, ptitle)
    return ptitle if ptitle.present?
    return nil if prospective_volume_id.nil?

    return Collection.find(prospective_volume_id).title_and_authors unless prospective_volume_id[0] == 'P'

    pub = Publication.find(prospective_volume_id[1..-1])
    return "#{pub.authority.name} – #{pub.title} (#{t(:new)}!)"
  end

  def cell_style(found_in_markdown, included)
    case [found_in_markdown, included]
    when [true, 'yes']
      'lgreenbg'
    when [false, 'yes']
      'lredbg'
    when [true, 'no']
      'lredbg'
    else
      ''
    end
  end

  def authorities_including_implicit(toc_text)
    aus = if toc_text.present?
            JSON.parse(toc_text)
          elsif @ingestible.default_authorities.present?
            JSON.parse(@ingestible.default_authorities)
          else
            []
          end

    if aus.present?
      return aus.map do |ia|
               "#{ia['authority_name'].presence || ia['new_person']} (#{textify_authority_role(ia['role'])})"
             end.join('<br />')
    end

    return t(:unknown)
  end
end
