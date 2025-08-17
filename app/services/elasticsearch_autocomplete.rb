# frozen_string_literal: true

# Service to do autocomplete lookups using ElasticSearch indices
class ElasticsearchAutocomplete < ApplicationService
  # @param term string to look for
  # @param index_class - class representing Chewy Index to use for search
  # @param fields - array of field names in index to search term in
  # @param filter (Hash or Array of Hashes) - optional ElasticSearch filter clause to do additional filtering of records
  # @param limit - max number of records to return
  # @return array of index_class instances matching provided term
  def call(term, index_class, fields, filter: nil, limit: 10)
    return [] if term.blank?

    should = fields.map { |f| { match_phrase_prefix: { f => { query: term } } } }

    query = index_class.send(:query, bool: { should: should, minimum_should_match: 1 })
    query = query.filter(filter) if filter.present?
    query.limit(limit).to_a
  end
end
