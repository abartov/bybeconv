class PeopleIndex < Chewy::Index

  # people
  define_type Person.all do #.joins([expressions: :works]).includes([expressions: :works]) do
    field :name
    field :sort_name, type: 'keyword'
    field :other_designation
    field :period, type: 'keyword'
    field :gender, type: 'keyword'
    field :impressions_count, type: 'integer'
    field :language, value: ->(person) { person.all_languages}, type: 'keyword'
    field :genre, value: ->(person) { person.all_genres}, type: 'keyword'
    field :public_domain, type: 'keyword' # TODO: make non boolean
    field :pby_publication_date, type: 'integer', value: ->(person){ person.works.count == 0 ? nil : person.works.order('created_at').first.created_at.year}
    field :birth_year, type: 'integer', value: ->(person){ person.birth_year == '?' ? nil : person.birth_year.to_i}
    field :death_year, type: 'integer', value: ->(person){ person.death_year == '?' ? nil : person.death_year.to_i}
    field :wikipedia_snippet
  end

end
