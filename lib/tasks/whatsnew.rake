desc "Create the 'what's new?' table as an HTML fragment to be pasted into the site's (static) main page"
task :whatsnew, [:fromdate] => :environment do |taskname, args|
  args.with_defaults(:fromdate => Date.today-30.days)
  print "args.fromdate seems to be #{args.fromdate}\n"

  thedir = AppConstants.base_dir # environment-sensitive constant
  tot = { :dir => 0, :files => 0, :new => 0, :upd => 0 }
  newfiles = HtmlFile.new_since(Date.new(args.fromdate))
  
  print "\n#{newfiles.count} new files found since #{args.fromdate}.\n"
  file_by_author = {}
  newfiles.each { |h|
    relpath = h.path.sub(AppConstants.base_dir,'')
    authordir = relpath[1..-1].sub(/\/.*/,'')
    author = author_name_from_dir(authordir)
    files_by_author[author] = '' if files_by_author[author].nil? # initialize array for author if first new work by that author
    files_by_author[author] += "<a href=\"#{relpath}\">#{title_from_file(h.path)}</a>; "
  }
  files_by_author.each {|a|
    # TODO: complete this
  }
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
    title.sub!(/ \x{2013}.*/, '') # ditto, with an em-dash
  end
  return title
end
def title_from_file(f)
  html = File.open(f, "r:windows-1255:UTF-8").read # slurp the file (lazy, I know)
  return title_from_html(html)
end        
def author_name_from_dir(d)
  html = File.open(AppConstants.base_dir+'/'+d+'/index.html', "r:windows-1255:UTF-8").read # slurp the file (lazy, I know)
  return title_from_html(html)
end
