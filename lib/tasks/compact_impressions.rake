namespace :impressions do
  desc 'Sum up and compact impressions records into YearTotals'
  task :compact, [:threshold] => :environment do |taskname, args|
    @threshold = args.threshold.to_i || 0
    done = 0
    while done < @threshold
      imp = Impression.order(:updated_at).first
      if imp.updated_at.year == Date.today.year # we're done compacting!
        puts 'No more impressions to compact! \o/'
        break
      end
      done += compact_item(imp.impressionable)
    end
    puts 'done!'
  end
end
private
def compact_item(item)
  return 0 if item.nil?
  print "Compacting #{item.class} #{item.id}... "
  total_impressions_to_compact = item.impressions.where('updated_at < ?', Date.new(Date.today.year)).count
  puts "#{total_impressions_to_compact} total impressions to compact."
  oldest_impression_year = item.impressions.order(:updated_at).first.updated_at.year
  (oldest_impression_year..Date.today.year-1).each do |year|
    total = item.impressions.where('updated_at < ? and updated_at > ?', Date.new(year+1), Date.new(year)).count
    puts "  Year #{year}: #{total} impressions."
    YearTotal.create!(year: year, total: total, item: item)
  end
  print '  Deleting old impressions... '
  item.impressions.where("updated_at < ?", Date.new(Date.today.year)).delete_all
  puts 'done!'
  return total_impressions_to_compact
end