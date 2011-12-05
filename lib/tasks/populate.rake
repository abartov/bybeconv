desc "Populate the DB with all the HtmlFiles from benyehuda"
task :populate => :environment do
  thedir = '/mnt/by'
  traverse(thedir)
end

private 
def traverse(dir)
  print "traversing #{dir}                \r"
  Dir.foreach(dir) { |fname|
    thefile = dir+'/'+fname
    if !(File.directory?(thefile)) and fname =~ /\.html$/
      h = HtmlFile.new(:path => thefile, :status => "Unknown")
      h.save!
    elsif File.directory?(thefile) and fname !~ /^_/ and fname !~ /^\./
      traverse(thefile) # recurse
    end
  }
end

