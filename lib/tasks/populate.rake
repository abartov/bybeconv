desc "Populate the DB with all the HtmlFiles from benyehuda, recording original mtime and ctime (run on Windows!)"
task :populate => :environment do
  thedir =  AppConstants.base_dir # environment-sensitive constant
  tot = { :dir => 0, :files => 0, :new => 0, :upd => 0 }
  traverse(thedir, tot)
  
  print "\n#{tot[:dir]} directories containing #{tot[:files]} files scanned: #{tot[:new]} new files found, #{tot[:upd]} files updated (status reset).\n"
end

private 
def traverse(dir, t)
  t[:dir]=t[:dir]+1
  print "traversing directory ##{t[:dir]} - #{dir}                \r"
  Dir.foreach(dir) { |fname|
    thefile = dir+'/'+fname
    if !(File.directory?(thefile)) and fname =~ /\.html$/ and not fname == 'index.html' and not dir == AppConstants.base_dir # ignore HTML files on root directory
      t[:files]=t[:files]+1
      h = HtmlFile.find_by_path(thefile)
      if h.nil?
        t[:new]=t[:new]+1
        h = HtmlFile.new(:path => thefile, :status => "Unknown", :orig_ctime => File.ctime(thefile), :orig_mtime => File.mtime(thefile))
        h.save!
      else
        if h.updated_at < File.mtime(thefile) # file updated since last analyzed
          t[:upd]=t[:upd]+1
          h.status = "Unknown"
          h.update_attribute(:updated_at, Time.now)
          h.save!
        end # else skip known files
      end
    elsif File.directory?(thefile) and fname !~ /^_/ and fname !~ /^\./ and not AppConstants.populate_exclude.split(';').include? fname
      traverse(thefile, t) # recurse
    end
  }
end

