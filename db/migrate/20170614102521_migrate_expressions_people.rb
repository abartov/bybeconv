class MigrateExpressionsPeople < ActiveRecord::Migration[4.2]
  def change
    puts "migrating expressions_people to realizers table"
    i = 0
    total = Expression.count
    Expression.all.each {|e|
      w = e.works[0]
      e.people.each {|p|
        unless e.persons.include?(p)
          r = Realizer.new(expression_id: e.id, person_id: p.id)
          if w.persons.include?(p)
            r.role = Realizer.roles[:author]
          else
            r.role = Realizer.roles[:translator]
          end
          r.save!
        end
      }
      i += 1
      puts "done #{i} out of #{total}" if i % 10 == 0
    }
    drop_table :expressions_people
  end
end
