# frozen_string_literal: true

# Lightweight index for autocomplete fields (includes non-published records too)
class AuthoritiesAutocompleteIndex < Chewy::Index
  index_scope Authority.all
  field :id, type: 'integer'
  field :name, type: 'search_as_you_type'
  field :other_designation, type: 'search_as_you_type'
  field :published, type: 'boolean', value: ->(a) { a.published? }
end
