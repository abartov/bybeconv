require 'multi_index_search_request'
class ManifestationsSearch
  include ActiveData::Model

  attribute :query, type: String
  attribute :genre, type: String
  attribute :min_orig_pub_year, type: Integer
  attribute :max_orig_pub_year, type: Integer
  attribute :tags, mode: :arrayed, type: String #, normalize: ->(value) { value.reject(&:blank?) }, default: ""

  # This accessor is for the form. It will have a single text field
  # for comma-separated tag inputs.
  def tag_list= value
    self.tags = value.split(',').map(&:strip)
  end

  def tag_list
    self.tags.join(', ')
  end

  def index
#    MultiIndexSearchRequest.new(ManifestationsIndex, PeopleIndex) # , ThirdIndex, ...) # just shorthand for our Chewy index class
    MultiIndexSearchRequest.new(ManifestationsIndex, PeopleIndex, DictIndex) # , ThirdIndex, ...) # just shorthand for our Chewy index class
  end

  def search
    # We can merge multiple scopes
    [query_string, genre_filter, orig_pub_year_filter, tags_filter, highlight, index_order].compact.reduce(:merge)
  end

  # Using query_string advanced query for the main query input
  def query_string
    index.query(query_string: {fields: ['title^10', 'alternate_titles^5', 'defhead^7', 'aliases^4', :name, :other_designation, :author_string, :fulltext, :deftext], query: query, default_operator: 'and'}) if query?
  end

  # Simple term filter for genre. ignored if empty.
  def genre_filter
    index.filter(term: {genre: genre}) if genre?
  end

  # For filtering on years, we will use range filter.
  # Returns nil if both min_year and max_year are not passed to the model.
  def orig_pub_year_filter
    body = {}.tap do |body|
      body.merge!(gte: min_orig_pub_year) if min_orig_pub_year?
      body.merge!(lte: max_orig_pub_year) if max_orig_pub_year?
    end
    index.filter(range: {orig_publication_date: body}) if body.present?
  end

  # here, for aggregate, `terms` filter used.
  # Returns nil if no tags passed in.
  def tags_filter
    index.filter(terms: {tags: tags}) if tags?
  end

  def highlight
    index.highlight(max_analyzed_offset: 999000, fields: {fulltext: {}, deftext: {}})
  end
  def index_order
    index.order(['_index' => {order: :desc}, '_score' => {order: :desc}]) # people before works, then by score
  end
end
