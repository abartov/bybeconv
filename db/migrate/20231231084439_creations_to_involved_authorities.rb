class CreationsToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    puts "migrating #{Creation.count} Creations to InvolvedAuthorities..."
    i = 0
    stale = 0
    Creation.all.each do |c|
      begin
        ia = InvolvedAuthority.create!(item_type: 'Work', item_id: c.work_id, authority_type: 'Person', authority_id: c.person_id, role: c.role)
        ia.update!(created_at: c.created_at, updated_at: c.updated_at)
        # when this major refactoring is done, a later migration would drop the Creations table
        i += 1
      rescue ActiveRecord::RecordInvalid => e
        stale += 1
      end
      puts "migrated #{i} Creations to InvolvedAuthorities" if i % 200 == 0
    end
    puts "Skipped #{stale} stale creations no longer pointing at existing items..."
    puts "done."
  end
end
