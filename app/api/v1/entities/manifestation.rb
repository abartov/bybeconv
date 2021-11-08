module V1
  module Entities
    class V1::Entities::Manifestation < Grape::Entity
      expose :id
      expose :url do |manifestation|
        Rails.application.routes.url_helpers.manifestation_read_url(manifestation)
      end
      expose :metadata do
        expose :title
        expose :sort_title
        expose :genre do |manifestation|
          manifestation.expressions[0].works[0].genre
        end
        expose :orig_lang do |manifestation|
          manifestation.expressions[0].works[0].orig_lang
        end
        expose :orig_lang_title do |manifestation|
          manifestation.expressions[0].works[0].origlang_title
        end
        expose :pby_publication_date do |manifestation|
          manifestation.expressions[0].works[0].created_at.to_date
        end
        expose :author_string
        expose :author_and_translator_ids, as: :author_ids
        expose :title_and_authors
        expose :impressions_count
        expose :orig_publication_date do |manifestation|
          normalize_date(manifestation.expressions[0].date)
        end
        expose :author_gender
        expose :translator_gender
        expose :copyright?, as: :copyright_status
        expose :period do |manifestation|
          manifestation.expressions[0].period
        end
        expose :raw_creation_date do |manifestation|
          manifestation.expressions[0].works[0].date
        end
        expose :creation_date do |manifestation|
          normalize_date(manifestation.expressions[0].works[0].date)
        end
        expose :place_and_publisher do |manifestation|
          "#{manifestation.publication_place}, #{manifestation.publisher}"
        end
        expose :raw_publication_date do |manifestation|
          manifestation.expressions[0].date
        end
        expose :publication_year do |manifestation|
          normalize_date(manifestation.expressions[0].date)&.year
        end
      end

      expose :snippet, if: lambda { |_manifestation, options| options[:view] == 'basic' } do |manifestation|
        snippet = snippet(manifestation.markdown, 500)[0]
        html = <<~HTML
          <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
          <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\">
          <head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>
          <body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">
            #{manifestation.title_and_authors_html}
            #{MultiMarkdown.new(snippet).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'')}
            </div>
          </body>
          </html>
          HTML
        txt = html2txt(html)
        txt.gsub("\n","\r\n") # windows linebreaks
      end

      expose :download_url do |manifestation|
        dl = GetFreshManifestationDownloadable.call(manifestation, options[:file_format])
        Rails.application.routes.url_helpers.rails_blob_url(dl.stored_file)
      end
    end
  end
end