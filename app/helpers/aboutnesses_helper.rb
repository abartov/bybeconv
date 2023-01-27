module AboutnessesHelper
  def aboutness_html(ab, edit)
    html = ''
    case ab.aboutable_type
    when 'Person'
      html += link_to(ab.aboutable.try(:name), author_toc_path(id: ab.aboutable_id))
      html += ' ('+I18n.t(:person)+')'
    when 'Work'
      html += link_to(ab.aboutable.try(:title), work_show_path(id: ab.aboutable_id))
      html += ' / '
      austr = ''
      ab.aboutable.authors.each do |au|
        austr += link_to(au.name, author_toc_path(id: au.id))+'; '
      end
      html += austr[0..-3]
      html += ' ('+I18n.t(:work)+')'
    when nil
      unless ab.wikidata_qid.nil?
        html += link_to("#{ab.wikidata_label}", 'https://wikidata.org/wiki/Q'+ab.wikidata_qid.to_s+'?uselang=he')
        html += ' ('+I18n.t(:wikidata_item)+')'
      else
        html = t(:unknown)
      end
    end
    if edit
      html += ' || '
      html += link_to(t(:destroy), url_for(controller: :aboutnesses, action: :remove, id: ab.id, manifestation_id: @m.id), :data => { :confirm => t(:are_you_sure) })
    end
  return html
  end

end
