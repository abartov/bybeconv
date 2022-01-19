class PeopleIndex < Chewy::Index

  # people
  define_type Person.published do #.joins([expressions: :works]).includes([expressions: :works]) do
    field :name
    field :sort_name, type: 'keyword'
    field :other_designation
    field :period, type: 'keyword'
    field :gender, type: 'keyword'
    field :any_hebrew_works, type: 'boolean', value: ->(person) {person.has_any_hebrew_works?}
    field :any_non_hebrew_works, type: 'boolean', value: ->(person) {person.has_any_non_hebrew_works?}
    field :impressions_count, type: 'integer'
    field :language, value: ->(person) { person.all_languages}, type: 'keyword'
    field :genre, value: ->(person) { person.all_genres}, type: 'keyword'
    field :copyright_status, value: ->(person) {person.public_domain ? false : true}, type: 'boolean' # TODO: make non boolean
    field :pby_publication_date, type: 'integer', value: ->(person){ person.works.count == 0 ? nil : person.works.order('created_at').first.created_at.year}
    field :birth_year, type: 'integer', value: ->(person){ person.birth_year == '?' ? nil : person.birth_year.to_i}
    field :death_year, type: 'integer', value: ->(person){ person.death_year == '?' ? nil : person.death_year.to_i}
    field :wikipedia_snippet
  end

end
