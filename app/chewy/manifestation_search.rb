class ManifestationSearch
  include ActiveModel::Model
  attr_accessor :query
  def index
    ManifestationIndex # just shorthand for our Chewy index class
  end

  def search
    index.query(query_string: {fields: [:title], query: query, default_operator: 'and'}) unless query.nil?
  end
end
