module V1
  module Entities
    class Person < Grape::Entity
      expose :id, documentation: { type: :Integer }
      expose :url do |person|
        Rails.application.routes.url_helpers.bib_person_url(person)
      end
      expose :metadata do
        expose :name
        expose :sort_name
        expose :birth_year, documentation: { type: 'Integer' }
        expose :death_year, documentation: { type: 'Integer' }
        expose :gender
        expose :copyright_status do |person|
          !person.public_domain?
        end
        expose :period
        expose :work_ids, if: lambda { |_person, options| !%w(metadata enriched).include?(options[:detail]) },
               documentation: { type: 'Integer', is_array: true, desc: 'ID numbers of all texts this person is involved with, filtered per the authorDetail param' } do |person, options|
          works = []
          if %w(works original_works full).include? options[:detail]
            works += person.creations.author.joins(work: {expressions: :manifestations}).pluck('manifestations.id')
          end
          if %w(works translations full).include? options[:detail]
            works += person.realizers.translator.joins(expression: :manifestations).pluck('manifestations.id')
          end
          works.uniq.sort
        end
        expose :other_designation, as: :other_designations,
               documentation: { desc: 'semicolon-separated list of additional names or spellings for this person' }
        expose :wikipedia_snippet, as: :bio_snippet
        expose :all_languages, as: :languages,
               documentation: { type: 'String', is_array: true, desc: 'list of languages (by ISO code) this person worked in' }
        expose :all_genres, as: :genres, documentation: { is_array: true }
        expose :impressions_count,
               documentation: { type: 'Integer', desc: "total number of times the person's page OR one of their texts were viewed or printed" }
      end

      expose :enrichment, if: lambda { |_person, options| %w(enriched full).include? options[:detail] } do
        expose :works_about,
               documentation: { type: 'Integer', is_array: true, desc: "ID numbers of texts whose subject is this person" } do |person|
          Aboutness.where(aboutable: person)
                   .joins(work: {expressions: :manifestations})
                   .pluck('manifestations.id').sort
        end
      end
    end
  end
end