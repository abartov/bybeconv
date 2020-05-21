module ManifestationHelper
  def options_from_images(images)
    # full resolution URL in value, thumbnail URL in imagesrc!
    actual_images = images.reject{|img| !img.variable?} # skip any non-image attachments that may have been accidentally uploaded
    return actual_images.map{|img| "<option value=\"#{url_for(img)}\" data-imagesrc=\"#{request.base_url+url_for(img.variant(resize: '150x150'))}\">#{img.blob.filename}</option>"}.join('')
  end
  def all_images_markdown(images)
    escape_javascript(images.map{|img| "\n![#{img.blob.filename}](#{url_for(img)})\n"}.join)
  end
end
