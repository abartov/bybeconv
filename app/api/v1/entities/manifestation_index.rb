module V1
  module Entities
    class ManifestationIndex < Grape::Entity
      expose :id
      expose :url do |manifestation|
        Rails.application.routes.url_helpers.manifestation_read_url(manifestation.id)
      end
      expose :metadata do
        expose :title
        expose :sort_title
        expose :genre
        expose :orig_lang
        expose :orig_lang_title
        expose :pby_publication_date do |manifestation|
          manifestation.pby_publication_date.to_date
        end
        expose :author_string
        expose :author_ids
        expose :title_and_authors do |manifestation|
          manifestation.title + ' / ' + manifestation.author_string
        end
        expose :impressions_count
        expose :orig_publication_date
        expose :author_gender
        expose :translator_gender
        expose :copyright_status
        expose :period
        expose :raw_creation_date
        expose :creation_date
        expose :place_and_publisher
        expose :raw_publication_date
        expose :publication_year do |manifestation|
          dt = manifestation.orig_publication_date
          dt.nil? ? nil : Time.parse(dt).year
        end
      end
      expose :enrichment, if: lambda { |_manifestation, options| options[:view] == 'enriched' } do |manifestation|
        V1::Entities::ManifestationEnrichment.represent manifestation.id
      end
      expose :txt_snippet, as: :snippet, if: lambda { |_manifestation, options| options[:snippet] }
      expose :download_url do |manifestation|
        Rails.application.routes.url_helpers.manifestation_download_url(manifestation.id, format: options[:file_format])
      end
    end
  end
end