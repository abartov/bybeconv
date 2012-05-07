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
    relpath = h.path.sub(AppConstants.base_dir,'')
    authordir = relpath[1..-1].sub(/\/.*/,'')
    author = author_name_from_dir(authordir, known_authors)
    files_by_author[author] = [] if files_by_author[author].nil? # initialize array for author if first new work by that author
    files_by_author[author].push "<a href=\"#{relpath}\">#{title_from_file(h.path)}</a>"
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

private 
def title_from_html(h)
  title = nil
  h.gsub!("\n",'') # ensure no newlines interfere with the full content of <title>...</title>
  if /<title>(.*)<\/title>/.match(h)
    title = $1
    res = /\//.match(title)
    if(res)
      title = res.pre_match
    end
    title.sub!(/ - .*/, '') # remove " - toxen inyanim"
    title.sub!(/ \u2013.*/, '') # ditto, with an em-dash
  end
  return title
end
def title_from_file(f)
  html = File.open(f, "r:windows-1255:UTF-8").read # slurp the file (lazy, I know)
  return title_from_html(html)
end        
def author_name_from_dir(d, known_names)
  if known_names[d].nil?
    mode = "r"
    mode += ":windows-1255:UTF-8" unless ["regelson", "ibnezra_m"].include? d # horrible, filthy, ugh!  But yeah, Regelson's index is in UTF-8, and not maintained in Word(!)
    html = File.open(AppConstants.base_dir+'/'+d+'/index.html', mode).read # slurp the file (lazy, I know)

    known_names[d] = title_from_html(html)
  end
  return known_names[d]
end
