module AboutnessesHelper
  def aboutness_html(ab, edit)
    html = ''
    case ab.aboutable_type
    when 'Person'
      html += link_to(ab.aboutable.name, author_toc_path(id: ab.aboutable_id))
      html += ' ('+I18n.t(:person)+')'
      if edit
        html += ' || '
        html += link_to(t(:destroy), url_for(controller: :aboutnesses, action: :remove, id: ab.id, manifestation_id: @m.id), :data => { :confirm => t(:are_you_sure) })
      end
    when 'Work'
      html += link_to(ab.aboutable.title, work_show_path(id: ab.aboutable_id))
      html += ' / '
      austr = ''
      ab.aboutable.authors.each do |au|
        austr += link_to(au.name, author_toc_path(id: au.id))+'; '
      end
      html += austr[0..-3]
      html += ' ('+I18n.t(:work)+')'
      if edit
        html += ' || '
        html += link_to(t(:destroy), url_for(controller: :aboutnesses, action: :remove, id: ab.id, manifestation_id: @m.id), :data => { :confirm => t(:are_you_sure) })
      end
    when nil
      unless ab.wikidata_qid.nil?
        html += '...'
      else
        html = t(:unknown)
      end
    end
    return html
  end

end
