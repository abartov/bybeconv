class BibSource < ActiveRecord::Base
  has_many :holdings
  has_many :publications
  enum source_type: [:aleph, :primo, :idea, :hebrewbooks, :googlebooks] # according to the types supported by the Gared gem
  enum status: [:enabled, :disabled]
end
