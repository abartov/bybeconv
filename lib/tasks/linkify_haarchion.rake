require 'csv'

desc 'Import Haarchion audio links from CSV'
task :linkify_haarchion, [:csv_file] => :environment do |taskname, args|
  lines = CSV.read(args.csv_file)[1..-1] # skip header row
  puts "Creating links for #{lines.size} records..."
  lines.each do |line|
    mid = line[4][line[4].rindex('/') + 1..-1]
    next if ExternalLink.exists?(url: line[5], linkable_id: mid,
                                 linkable_type: 'Manifestation')

    ExternalLink.create!(url: line[5],
                         description: 'להקראת היצירה באתר הארכיון - ספרות עברית בקול',
                         status: :approved,
                         linktype: :audio,
                         linkable_id: mid,
                         linkable_type: 'Manifestation')
  end
  puts 'done.'
end
