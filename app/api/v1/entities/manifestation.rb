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
        expose :place_and_publisher
        expose :raw_publication_date do |manifestation|
          manifestation.expressions[0].date
        end
        expose :publication_year do |manifestation|
          normalize_date(manifestation.expressions[0].date)&.year
        end
      end

      expose :txt_snippet, as: :snippet, if: lambda { |_manifestation, options| options[:view] == 'basic' }

      expose :download_url do |manifestation|
        Rails.application.routes.url_helpers.manifestation_download_url(manifestation, format: options[:file_format])
      end
    end
  end
end