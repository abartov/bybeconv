require 'bybe_utils'
require 'htmlentities'
require 'csv'
include BybeUtils

desc "go over all published defs looking for sources in sources markup"
task :pseudocatalogue => :environment do
  coder = HTMLEntities.new
  known_authors = {}
  done = 0
  puts "Generating pseudo-catalogue..."
  File.open('pseudocatalogue.csv', 'w') {|f|
    HtmlFile.all.each {|h|
      puts "...#{done}" if done % 100 == 0
      relpath = h.path.sub(AppConstants.base_dir,'')
      authordir = relpath[1..-1].sub(/\/.*/,'')
      author = author_name_from_dir(authordir, known_authors)
      f.puts([h.url, HtmlFile.title_from_file(h.path), author].map {|s| s.nil? ? '' : coder.decode(s.force_encoding('UTF-8')) }.to_csv)
      done += 1
    }
  }
  puts "\nDone! Exported work and author information from HTML files to ./pseudocatalogue.csv"
end

