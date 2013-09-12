desc "Populate the DB with all the HtmlFiles from benyehuda, recording original mtime and ctime (run on Windows!)"
task :populate => :environment do
  thedir =  AppConstants.base_dir # environment-sensitive constant
  tot = { :dir => 0, :files => 0, :new => 0, :upd => 0 }
  no_nikkuds = []
  traverse(thedir, tot, no_nikkuds)
  File.open(AppConstants.base_dir+'/no_nikkud_index.html', 'w') {|f|
    f.write("<html><body><h1>Nothing to see here</h1>\n")
    no_nikkuds.each {|url|
      f.write("<a href=\"#{url}\">#{url}</a>\n")
    }
    f.write('</body></html>')
  }
  print "\n#{tot[:dir]} directories containing #{tot[:files]} files scanned: #{tot[:new]} new files found, #{tot[:upd]} files updated (status reset)\n#{no_nikkuds.length} no-nikkud files listed in new no_nikkud_index.html just generated.\n"
end

private 
def fix_links(f)
  # bad links look like this:  <a href="&#22649;&#62593;&#7483;&#18559;&#11439;&#23938;&#34244;&#25383;"> and should be <a href="/">
  raw = IO.binread(f)
  if /&#22649;&#62593;&#7483;&#18559;&#11439;&#23938;&#34244;&#25383;/.match(raw)
    puts "fixed old bad root link in #{f}"
    IO.binwrite(f, raw.gsub('<a href="&#22649;&#62593;&#7483;&#18559;&#11439;&#23938;&#34244;&#25383;">','<a href="/">'))
  end
end

def traverse(dir, t, no_nikkuds)
  t[:dir] += 1
  print "traversing directory ##{t[:dir]} - #{dir}                     \r"
  Dir.foreach(dir) { |fname|
    thefile = dir+'/'+fname
    if !(File.directory?(thefile)) and fname =~ /\.html$/ and not fname == 'index.html' and fname !~ /_no_nikkud/ and not dir == AppConstants.base_dir # ignore HTML files on root directory
      t[:files] += 1
      h = HtmlFile.find_by_path(thefile)
      if h.nil?
        t[:new] += 1
        h = HtmlFile.new(:path => thefile, :url => thefile.sub(AppConstants.base_dir,''), :status => "Unknown", :orig_ctime => File.ctime(thefile), :orig_mtime => File.mtime(thefile))
        h.save!
      else
        if h.updated_at < File.mtime(thefile) # file updated since last analyzed
          t[:upd] += 1
          h.status = "Unknown"
          h.stripped_nikkud = false # may need to re-strip 
          h.update_attribute(:updated_at, Time.now)
          h.save!
        end # else skip known files
      end
      fix_links(thefile) # fix bad root links caused by a bug in Word's template handling
    elsif File.directory?(thefile) and fname !~ /^_/ and fname !~ /^\./ and not AppConstants.populate_exclude.split(';').include? fname
      traverse(thefile, t, no_nikkuds) # recurse
    elsif fname =~ /_no_nikkud/
      no_nikkuds << thefile.sub(AppConstants.base_dir+'/','') # relative path from where the index will be
    end
  }
end

