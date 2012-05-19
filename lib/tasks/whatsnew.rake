desc "Create the 'what's new?' table as an HTML fragment to be pasted into the site's (static) main page"
task :whatsnew, [:fromdate] => :environment do |taskname, args|
  args.with_defaults(:fromdate => (Date.today-30.days).to_s)
  print "args.fromdate seems to be #{args.fromdate}\n"
  known_authors = {}
  thedir = AppConstants.base_dir # environment-sensitive constant
  tot = { :dir => 0, :files => 0, :new => 0, :upd => 0 }
  newfiles = HtmlFile.new_since(Date.parse(args.fromdate).to_time)
  
  print "\n#{newfiles.count} new files found since #{args.fromdate}.\n"
  files_by_author = {}
  progress = 0
  newfiles.each { |h|
    author = HtmlFile.author_name_from_dir(h.author_dir, known_authors)
    files_by_author[author] = [] if files_by_author[author].nil? # initialize array for author if first new work by that author
    files_by_author[author].push "<a href=\"#{relpath}\">#{HtmlFile.title_from_file(h.path)}</a>"
    print "\rHandled #{progress} files so far.     " if progress % 10 == 0
    progress += 1
  }
  print "\nEmitting whatsnew.html... "
  File.open("whatsnew.html", "w") {|f|
    f.write('<?xml version="1.0" encoding="utf8"?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="he"><body dir="rtl" align="right"><table>')
    files_by_author.each {|a, files|
      #print "DBG: a = #{a}\n"
      #print "DBG: files = #{files.join('\; ')}\n"

      f.write("<tr><td>#{a}:</td><td><b><u>_______:</u></b> #{files.join('; ')}</td></tr>")
    }
    f.write('</table></body></html>')
  }
  print "done!\n"
end

