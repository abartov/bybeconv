class CreationsToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    puts "migrating #{Creation.count} Creations to InvolvedAuthorities..."
    i = 0
    Creation.all.each do |c|
      ia = InvolvedAuthority.create!(item_type: 'Work', item_id: c.work_id, authority_type: 'Person', authority_id: c.person_id, role: c.role)
      ia.update!(created_at: c.created_at, updated_at: c.updated_at)
      # when this major refactoring is done, a later migration would drop the Creations table
      i += 1
      puts "migrated #{i} Creations to InvolvedAuthorities" if i % 200 == 0
    end
    stale = InvolvedAuthority.where.missing(:work)
    puts "Removing #{stale.count} stale creations no longer pointing at existing items..."
    stale.destroy_all
    puts "done."
  end
end
