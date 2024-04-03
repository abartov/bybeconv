# base class for Person and CorporateBody

module Authority

  def authority_works_count
    created_work_ids = self.works.includes(expressions: [:manifestations]).where(manifestations: {status: :published}).pluck(:id)
    expressions_work_ids = self.expressions.includes(:manifestations).where(manifestations: {status: :published}).pluck(:work_id)
    (created_work_ids + expressions_work_ids).uniq.size
  end

  def latest_stuff
    latest_original_works = Manifestation.all_published.joins(expression: [work: :involved_authorities]).includes(:expression).where(involved_authorities: {authority: self}).order(created_at: :desc).limit(20)

    latest_translations = Manifestation.all_published.joins(expression: :involved_authorities).includes(expression: [work: :involved_authorities]).where(involved_authorities:{role: :translator, authority: self}).order(created_at: :desc).limit(20)

    return (latest_original_works + latest_translations).uniq.sort_by{|m| m.created_at}.reverse.first(20)
  end

  def original_works_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.all_published.joins(expression: [work: :involved_authorities]).includes(:expression).where(involved_authorities: {authority: self}).each do |m|
      ret[m.expression.work.genre] << m
    end
    return ret
  end

  def translations_by_genre
    ret = {}
    get_genres.map{|g| ret[g] = []}
    Manifestation.all_published.joins(expression: :involved_authorities).includes(expression: :work).where(involved_authorities:{role: :translator, authority: self}).each do |m|
      ret[m.expression.work.genre] << m
    end
    return ret
  end

end