desc "Update the sort titles for all works (only needed if logic changed)"
task :update_sort_title => :environment do
  Chewy.strategy(:atomic) do
    puts "Populating sort_title column..."
    total = Manifestation.count
    i = 0
    Manifestation.all.each do |m|
      puts "#{i}/#{total} done" if i % 100 == 0
      m.update_sort_title
      m.save
      i += 1
    end
    puts "Updating ElasticSearch..."
  end
  puts "done!"
end
