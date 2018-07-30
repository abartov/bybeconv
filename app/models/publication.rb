class Publication < ActiveRecord::Base
  belongs_to :person
  belongs_to :bib_source
  has_many :holdings, :dependent => :destroy
  enum status: [:todo, :scanned, :obtained, :uploaded, :irrelevant]

  scope :pubs_to_obtain, -> (source_id) { where(status: 'todo', bib_source_id: source_id)}
  scope :genre, -> (genre) { joins(:expressions).includes(:expressions).where(expressions: {genre: genre})}

end
