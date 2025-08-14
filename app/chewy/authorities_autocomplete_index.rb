# frozen_string_literal: true

# Lightweight index for autocomplete fields (includes non-published records too)
class AuthoritiesAutocompleteIndex < Chewy::Index
  index_scope Authority.all
  field :id, type: 'integer'
  field :name
  field :other_designation
  field :published, type: 'boolean', value: ->(a) { a.published? }
end
