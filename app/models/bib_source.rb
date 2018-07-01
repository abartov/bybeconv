class BibSource < ActiveRecord::Base
  enum source_type: [:aleph, :primo, :idea, :hebrewbooks, :googlebooks] # according to the types supported by the Gared gem
  enum status: [:enabled, :disabled]
end
