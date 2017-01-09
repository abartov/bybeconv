desc "ingest an index.html file and create a Toc"
task :ingest_toc, [:dirname] => :environment do |taskname, args|
  thedir = AppConstants.base_dir
  if args.dirname.nil?
    puts "run again with a PBY dir name, e.g. rake ingest_toc[bialik]"
    exit
  end
  thedir += "/#{args.dirname}"
  unless Dir.exists?(thedir)
    puts "no such directory #{thedir}"
    exit
  end
  print "Reading... "
  begin
    fname = File.exists?(thedir+'/index.html.utf8') ? 'index.html.utf8' : 'index.html'
    die "Index file is not UTF-8! Can't proceed." unless `file #{thedir}/#{fname}` =~ /UTF-8/
    utfindex = File.open("#{thedir}/#{fname}", 'r:UTF-8').read.gsub("\r\n","\n")
    puts "success!"
    new_toc = process_index(args.dirname, utfindex)
  rescue
    puts "bad encoding. Run\n\nrake badchar[full_path_to_offending_file]\n\n to find what doesn't convert well."
  end
  dir = HtmlDir.find_by_path(args.dirname)
  p = dir.person
  unless p.nil?
    p.toc = new_toc
    p.save!
  end
end

def process_index(dirname, blob)
  m = blob.match(/<body.*?>/)
  die("can't understand this file structure!") if m.nil?
  body = $'.gsub(/<a(.*?)>(.*?)<\/a>/m,"[[a \\1]]\\2[[/a]]") # replace all links with placeholders
  body = body.gsub('</p>','XYZZY') # save actual paragraph ends
  body = body.gsub(/<.*?>/m,'') # remove all remaining HTML tags
  body = body.gsub('&nbsp;',' ') # remove hard spaces
  body = body.gsub('&#x000A;',"\n")
  body = body.gsub("\n",' ') # remove random HTML linebreaks
  body = body.gsub('  ',' ') # condense spaces
  body = body.gsub('XYZZY',"\n\n") # restore paragraph ends as linebreaks
  buf = body
  linked_body = ''
  until buf.empty?
    m = buf.match(/\[\[a (.*?)\]\](.*?)\[\[\/a\]\]/m)
    if m.nil?
      linked_body += buf
      buf = ''
    else
      linked_body += $`
      linked_body += match_link(dirname, $1, $2)
      buf = $'
    end
  end
  lines = linked_body.split "\n"
  lines.each {|l| l.strip!}
  linked_body = lines.join ("\n")
  linked_body = section_titles(linked_body)
  toc = Toc.new(toc: linked_body, status: 'Raw')
  toc.save
  return toc
end

def section_titles(buf)
  ['שירה','פרוזה','מאמרים ומסות','מאמרים, מסות, ועיון','עיון','יומנים ומכתבים','אגרות','תרגום','איגרות','זכרונות','מסות ומאמרים','מאמרים, מסות ועיון'].each {|title|
    buf = buf.gsub("\n"+title, "\n## #{title}\n") # gsub, just in case there's a work with the genre name -- the mistake would be obvious and easy to fix manually
  }
  buf.gsub!("\n·","\n*")
  return buf
end

def match_link(dirname, target, text)
  return '' if target.strip[0..3] == 'name'
  m = target.match(/href="(.*)"/)
  return '' if m.nil?
  url = $1
  return '' if ['index.html','/','mailto:editor@benyehuda.org'].include?(url)
  return "[#{text}](#{url})" if url[0..3].upcase == 'HTTP' # preserve absolute links
  h = HtmlFile.where(url: "/#{dirname}/#{url}")
  if h.empty?
    puts "ERROR: can't find HtmlFile for url #{dirname}/#{url}"
    return "ERROR: #{text} ----> #{target}\n"
  end
  thefile = h[0]
  if thefile.manifestations.empty?
    the_id = "ה#{thefile.id}"
  else
    the_id = "מ#{thefile.manifestations[0].id}"
  end
  return "&&&פריט: #{the_id} &&&כותרת: #{text.gsub("\n",' ').gsub('&nbsp;',' ').strip}&&&"
end

def die(msg)
  puts msg
  exit
end
