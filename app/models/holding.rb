class Holding < ActiveRecord::Base
  attr_accessible :location, :publication_id, :source_id, :scan_url, :status
  belongs_to :publication
  belongs_to :bib_source
  enum status: [:todo, :scanned, :obtained, :missing]

  scope :to_obtain, -> (source_id) { where(status: 'todo', bib_source_id: source_id)}

end
