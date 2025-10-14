# Checks if Manifestation's Downloadable exists for the given format
# If exists but outdated it updates blob with fresh data, if not exists it creates new Downloadable for a file
class GetFreshManifestationDownloadable < ApplicationService
  # @return fresh Manifestation downloadable for given file format
  def call(manifestation, format)
    dl = manifestation.fresh_downloadable_for(format)
    if dl.nil?
      filename = "#{manifestation.safe_filename}.#{format}"
      # html = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>#{manifestation.title_and_authors}</title></head><body dir='rtl' style='text-align:right'><div dir=\"rtl\" style=\"text-align:right\">#{manifestation.title_and_authors_html}"+MultiMarkdown.new(manifestation.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'')+"\n\n<hr />"+I18n.t(:download_footer_html, url: Rails.application.routes.url_helpers.url_for(controller: :manifestation, action: :read, id: manifestation.id))+"</div></body></html>"
      html = "<div dir=\"rtl\" style=\"text-align:right\">#{manifestation.title_and_authors_html}" + MultiMarkdown.new(manifestation.markdown).to_html.force_encoding('UTF-8').gsub(
        %r{<figcaption>.*?</figcaption>}, ''
      ) + "\n\n<hr />" + I18n.t(:download_footer_html,
                                url: Rails.application.routes.url_helpers.url_for(controller: :manifestation, action: :read,
                                                                                  id: manifestation.id)) + '</div>'
      dl = MakeFreshDownloadable.call(format, filename, html, manifestation, manifestation.author_string)
    end
    return dl
  end
end
