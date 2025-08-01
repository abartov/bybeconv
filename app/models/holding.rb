class Holding < ApplicationRecord
  # attr_accessible :location, :publication_id, :source_id, :scan_url, :status
  belongs_to :publication
  belongs_to :bib_source
  enum :status, { todo: 0, scanned: 1, obtained: 2, missing: 3 }

  scope :to_obtain, -> (source_id) { includes(:publication).where(status: 'todo', bib_source_id: source_id)}

  def recno
    ret = ''
    if source_id =~ /doc_number=(\d+)/
      ret = $1
    end
    return ret
  end
end
