module AuthorsHelper
  def authors_label_by_gender_filter(gender_filter, total)
    if gender_filter.blank?
      return t(:x_authors_mixed_gender, {x: total})
    elsif gender_filter == 'female'
      return t(:x_authors_female, {x: total})
    else
      return t(:x_authors_male, {x: total})
    end # TODO: support more genders
  end

  def browse_item_decorator_by_sort_type(sort_type)
    case sort_type
    when /publ/
      return method(:browse_pub_date)
    when /cre/
      return method(:browse_creation_date)
    when /upl/
      return method(:browse_upload_date)
    else
      return method(:browse_null_decorator)
    end
  end
  def browse_pub_date(item)
    thedate = item.expressions[0].normalized_pub_date
    return " (#{thedate.nil? ? t(:unknown) : thedate.to_date.strftime('%d-%m-%Y')})"
  end
  def browse_creation_date(item)
    thedate = item.expressions[0].works[0].normalized_creation_date
    return " (#{thedate.nil? ? t(:unknown) : thedate.to_date.strftime('%d-%m-%Y')})"
  end
  def browse_upload_date(item)
    return " (#{item.created_at.strftime('%d-%m-%Y')})"
  end
  def browse_null_decorator(item)
    return ''
  end
end