class RealizersToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    puts "migrating #{Realizer.count} Realizers to InvolvedAuthorities..."
    i = 0
    stale = 0
    Realizer.all.each do |r|
      begin
        ia = InvolvedAuthority.create!(item_type: 'Expression', item_id: r.expression_id, authority_type: 'Person', authority_id: r.person_id, role: r.role)
        ia.update!(created_at: r.created_at, updated_at: r.updated_at)
        # when this major refactoring is done, a later migration would drop the Realizers table
        i += 1
      rescue ActiveRecord::RecordInvalid => e
        stale += 1
      end
      puts "migrated #{i} Realizers to InvolvedAuthorities" if i % 200 == 0
    end
    puts "Skipped #{stale} stale realizers no longer pointing at existing items..."
    puts "done."
  end
end
