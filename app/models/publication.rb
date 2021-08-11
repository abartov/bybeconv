class Publication < ApplicationRecord
  belongs_to :person
  belongs_to :bib_source
  has_many :holdings, :dependent => :destroy
  has_many :list_items, as: :item

  enum status: [:todo, :scanned, :obtained, :uploaded, :irrelevant, :copyrighted]

  scope :pubs_to_obtain, -> (source_id) { where(status: 'todo', bib_source_id: source_id)}
  scope :genre, -> (genre) { joins(:expressions).includes(:expressions).where(expressions: {genre: genre})}
  scope :not_uploaded, -> {where.not(status: 'uploaded')}
  scope :maybe_done, -> {joins(:list_items).where(list_items: {listkey: 'pubs_maybe_done'})}
  scope :not_maybe_done, -> {where.not(id: ListItem.select(:item_id).where(listkey: 'pubs_maybe_done'))}
  scope :false_positive_maybe_done, ->{joins(:list_items).where(list_items: {listkey: 'pubs_false_maybe_done'})}
  scope :not_false_positive_maybe_done, -> {where.not(id: ListItem.select(:item_id).where(listkey: 'pubs_false_maybe_done'))}

  after_save :check_lists

  def self.update_publications_that_may_be_done_list
    coll = Publication.not_uploaded.not_maybe_done.not_false_positive_maybe_done
    total = coll.count
    # TODO: optimize to group the above by author and then check all author pubs against all extant manifestations of author at the same time
    coll.each do |pub|
      mm = pub.person.all_works_by_title(pub_title_for_comparison(pub.title))
      unless mm.empty?
        li = ListItem.new(listkey: 'pubs_maybe_done', item: pub)
        li.save!
      end
    end
  end
  def check_lists
    if(self.status == 'uploaded')
      lis = self.list_items.where(listkey: ['pubs_maybe_done', 'pubs_false_maybe_done'])
      lis.destroy_all # remove temporary maintenance list_items once publication is uploaded
    end
  end
end
