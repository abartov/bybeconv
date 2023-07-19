class FixImpressionCounts < ActiveRecord::Migration[6.1]
  def change
    i = 0
    total = Person.count
    puts "Fixing impression counts for #{total} people..."
    Person.all.each do |person|
      old = person.impressions_count
      person.update_impression
      newc = person.impressions_count
      puts "  #{person.name}: #{old} --> #{newc} impressions" if old != newc
      i += 1
      puts "Updated #{i} of #{total} people" if i % 50 == 0
    end
    puts "Finished at #{Time.now}"
  end
end