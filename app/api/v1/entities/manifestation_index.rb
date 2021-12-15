module V1
  module Entities
    class ManifestationIndex < Grape::Entity
      expose :id, documentation: { type: 'Integer' }
      expose :url, documentation: { desc: 'Canonical URL of the text at Project Ben-Yehuda (useful for giving credit and allowing users to click through)' } do |manifestation|
        Rails.application.routes.url_helpers.manifestation_read_url(manifestation.id)
      end
      expose :metadata do
        expose :title
        expose :sort_title, documentation: { desc: 'version of the title more useful for alphabetical sorting' }
        expose :genre, documentation: { values: Work::GENRES }
        expose :orig_lang
        expose :orig_lang_title, documentation: { desc: 'title of translated text in the original language and script' }
        expose :pby_publication_date do |manifestation|
          manifestation.pby_publication_date.to_date
        end
        expose :author_string
        expose :author_ids, documentation: { type: 'Integer', is_array: true, desc: 'ID numbers of all authors involved with the text (most often only one)' }
        expose :title_and_authors do |manifestation|
          manifestation.title + ' / ' + manifestation.author_string
        end
        expose :impressions_count, documentation: { type: 'Integer', desc: 'total number of times the text was viewed or printed' }
        expose :orig_publication_date
        expose :author_gender, documentation: { values: ::Person.genders.keys, is_array: true }
        expose :translator_gender, documentation: { values: ::Person.genders.keys, is_array: true }
        expose :copyright_status, documentation: { type: 'Boolean' }
        expose :period, documentation: { values: Expression.periods.keys }
        expose :raw_creation_date
        expose :creation_date
        expose :place_and_publisher
        expose :raw_publication_date
        expose :publication_year, documentation: { type: 'Integer' } do |manifestation|
          dt = manifestation.orig_publication_date
          dt.nil? ? nil : Time.parse(dt).year
        end
      end
      expose :id, as: :enrichment, using: V1::Entities::ManifestationEnrichment, if: lambda { |_manifestation, options| options[:view] == 'enriched' }
      expose :txt_snippet, as: :snippet,
             documentation: { desc: 'plaintext snippet of the first few hundred characters of the text, useful for previews and search results' },
             if: lambda { |_manifestation, options| options[:snippet] }
      expose :download_url,
             documentation: { desc: 'URL of the full text of the work, in the requested format (HTML by default)' } do |manifestation|
        Rails.application.routes.url_helpers.manifestation_download_url(manifestation.id, format: options[:file_format])
      end
    end
  end
end