class MoveEmptyAuthorsToAwaitingFirst < ActiveRecord::Migration[5.2]
  def change
    print "Updating public domain authors with no works to awaiting_first... "
    Person.where(public_domain: true).each { |p| p.awaiting_first! unless p.original_work_count_including_unpublished + p.translations_count_including_unpublished > 0 }
    puts "done."
  end
end
