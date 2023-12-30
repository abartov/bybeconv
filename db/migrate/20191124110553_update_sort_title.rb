class UpdateSortTitle < ActiveRecord::Migration[5.2]
  def change
    puts "Populating sort_title column..."
    total = Manifestation.count
    i = 0
    Manifestation.all.each do |m|
      puts "#{i}/#{total} done" if i % 100 == 0
      m.update_sort_title!
      m.save
      i += 1
    end
  end
end
