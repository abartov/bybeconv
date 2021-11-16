module ManifestationHelper
  # NOTE: these URLs depends on secret_key_base -- once one is generated or change for the app, all URLs change.
  # out current implementation *stores* the URLs with the digests *in the markdown* of the works, meaning they can
  # all suddenly break if secret_key_base is changed.
  def options_from_images(images)
    # full resolution URL in value, thumbnail URL in imagesrc!
    actual_images = images.reject{|img| !img.variable?} # skip any non-image attachments that may have been accidentally uploaded
    return actual_images.map{|img| "<option value=\"#{url_for(img)}\" data-imagesrc=\"#{request.base_url+url_for(img.variant(resize: '150x150'))}\">#{img.blob.filename}</option>"}.join('')
  end
  def all_images_markdown(images)
    escape_javascript(images.map{|img| "\n![#{img.blob.filename}](#{url_for(img)})\n"}.join)
  end
  def authorlist_decorator_by_sort_type(sort_type)
    case sort_type
    when /birth/
      return method(:author_birth_date_decorator)
    when /death/
      return method(:author_death_date_decorator)
    when /upl/
      return method(:browse_upload_date)
    else
      return method(:browse_null_decorator)
    end
  end
  def author_birth_date_decorator(item)
    thedate = item.normalized_birth_date
    return " (#{thedate.nil? ? t(:unknown) : thedate.to_date.strftime('%d-%m-%Y')})"
  end
  def author_death_date_decorator(item)
    thedate = item.normalized_death_date
    return " (#{thedate.nil? ? t(:unknown) : thedate.to_date.strftime('%d-%m-%Y')})"
  end
  def browse_upload_date(item)
    return " (#{item.pby_publication_date.to_date.strftime('%d-%m-%Y')})"
  end
  def browse_null_decorator(item)
    return ''
  end
end
