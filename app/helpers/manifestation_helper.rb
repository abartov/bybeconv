module ManifestationHelper
  def options_from_images(images)
    # full resolution URL in value, thumbnail URL in imagesrc!
    images.map{|img| "<option value=\"#{url_for(img)}\" data-imagesrc=\"#{request.base_url+url_for(img.variant(resize: '150x150'))}\">#{img.blob.filename}</option>"}.join('')
  end
end
