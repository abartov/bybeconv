class Publication < ApplicationRecord
  belongs_to :authority, inverse_of: :publications
  belongs_to :bib_source
  has_many :holdings, dependent: :destroy
  has_many :list_items, as: :item, dependent: :destroy

  enum status: [:todo, :scanned, :obtained, :uploaded, :irrelevant, :copyrighted]

  scope :pubs_to_obtain, -> (source_id) { where(status: 'todo', bib_source_id: source_id)}
  scope :not_uploaded, -> {where.not(status: 'uploaded')}
  scope :maybe_done, -> {joins(:list_items).where(list_items: {listkey: 'pubs_maybe_done'})}
  scope :not_maybe_done, -> {where.not(id: ListItem.select(:item_id).where(listkey: 'pubs_maybe_done'))}
  scope :false_positive_maybe_done, ->{joins(:list_items).where(list_items: {listkey: 'pubs_false_maybe_done'})}
  scope :not_false_positive_maybe_done, -> {where.not(id: ListItem.select(:item_id).where(listkey: 'pubs_false_maybe_done'))}

  after_save :check_lists

  def self.update_publications_that_may_be_done_list
    coll = Publication.not_uploaded.not_maybe_done.not_false_positive_maybe_done.order(:person_id)
    total = coll.count
    author_title_cache = []
    last_author = nil
    i = 1
    added = 0
    coll.each do |pub|
      print "\nHandling #{i} out of #{total}..." if i % 50 == 0
      if pub.person_id != last_author
        last_author = pub.person_id
        author_title_cache = pub.person.all_works_title_sorted.pluck(:title)
      end
      searchtitle = pub_title_for_comparison(pub.title)
      if author_title_cache.include?(searchtitle)
        li = ListItem.new(listkey: 'pubs_maybe_done', item: pub)
        li.save!
        added += 1
      end
      i += 1
    end
    puts "...done!\n Added #{added} new maybe_done ListItems."
  end
  def check_lists
    if(self.status == 'uploaded')
      lis = self.list_items.where(listkey: ['pubs_maybe_done', 'pubs_false_maybe_done'])
      lis.destroy_all # remove temporary maintenance list_items once publication is uploaded
    end
  end
end
