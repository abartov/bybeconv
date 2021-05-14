class BibSource < ApplicationRecord
  has_many :holdings
  has_many :publications
  enum source_type: [:aleph, :primo, :idea, :hebrewbooks, :googlebooks, :nli_api] # according to the types supported by the Gared gem
  enum status: [:enabled, :disabled]

  scope :physical_sources, -> { where(status: 'enabled', source_type: [BibSource.source_types[:aleph], BibSource.source_types[:primo], BibSource.source_types[:idea]])}

end
