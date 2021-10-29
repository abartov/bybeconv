class AddCachedPeopleToManifestation < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestations, :cached_people, :string
    # populate the field once
    puts "populating cached_people"
    i = 0
    total = Manifestation.count
    Manifestation.all.each {|m|
      begin
      pp = []
      m.expressions.each {|e|
        e.persons.each {|p| pp << p unless pp.include?(p) }
        e.works.each {|w|
          w.persons.each {|p| pp << p unless pp.include?(p) }
        }
      }
      m.cached_people = pp.map{|p| p.name}.join('; ')
      m.save!
      rescue
        puts "error: #{$!}"
      end
      i += 1
      puts "done #{i} out of #{total}  " if i % 10 == 0
    }
  end
  def down
    remove_column :manifestations, :cached_people
  end
end
