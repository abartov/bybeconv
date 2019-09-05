class PeopleIndex < Chewy::Index

  # people
  define_type Person.all do #.joins([expressions: :works]).includes([expressions: :works]) do
    field :name
    field :period
    field :gender
    field :public_domain
    field :birth_year, type: 'integer', value: ->(person){ person.birth_year == '?' ? nil : person.birth_year.to_i}
    field :death_year, type: 'integer', value: ->(person){ person.death_year == '?' ? nil : person.death_year.to_i}
    field :wikipedia_snippet
  end

end
