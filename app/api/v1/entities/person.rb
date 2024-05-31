module V1
  module Entities
    class Person < Grape::Entity
      expose :id, documentation: { type: :Integer }
      expose :url, documentation: {
        desc: 'Canonical URL of the person at Project Ben-Yehuda (useful for giving credit and allowing' \
              'users to click through)'
      } do |au|
        Rails.application.routes.url_helpers.authority_url(au)
      end
      expose :metadata do
        expose :name
        expose :sort_name,  documentation: { desc: 'version of the name more useful for alphabetical sorting' }
        expose :birth_year, documentation: { type: 'Integer' } do |au|
          au.person.birth_year
        end
        expose :death_year, documentation: { type: 'Integer' } do |au|
          au.person.death_year
        end
        expose :gender, documentation: { values: ::Person.genders.keys } do |au|
          au.person.gender
        end
        expose :intellectual_property, documentation: { values: ::Authority.intellectual_properties.keys }
        expose :period, documentation: { values: ::Person.periods.keys } do |au|
          au.person.period
        end
        expose :other_designation, as: :other_designations,
               documentation: { desc: 'semicolon-separated list of additional names or spellings for this person' }
        expose :wikipedia_snippet, as: :bio_snippet
        expose :all_languages, as: :languages,
               documentation: { type: 'String', is_array: true, desc: 'list of languages (by ISO code) this person worked in' }
        expose :all_genres, as: :genres, documentation: { values: Work::GENRES, is_array: true }
        expose :impressions_count,
               documentation: { type: 'Integer', desc: "total number of times the person's page OR one of their texts were viewed or printed" }
      end

      expose :texts,
             documentation: { desc: 'ID numbers of all texts this person is involved in, with role in each' },
             if: ->(_person, options) { %w(texts enriched).include?(options[:detail]) } do
               InvolvedAuthority.roles.each_key do |role|
                 expose role, documentation: { type: 'Integer', is_array: true } do |person|
                   person.published_manifestations(role).pluck('manifestations.id').sort
                 end
               end
             end

      expose :enrichment, if: lambda { |_person, options| %w(enriched).include? options[:detail] } do
        expose :texts_about,
               documentation: {
                 type: 'Integer', is_array: true,
                 desc: 'ID numbers of texts whose subject is this person'
               } do |person|
          Aboutness.where(aboutable: person)
                   .joins(work: {expressions: :manifestations})
                   .pluck('manifestations.id').sort
        end
      end
    end
  end
end
