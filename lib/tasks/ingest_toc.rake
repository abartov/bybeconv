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
    # DEBUG utfindex = File.open(thedir+'/index.html', 'r:window-1255:UTF-8').read
    utfindex = File.open('by_index_utf8.html').read
    puts "success!"
    new_toc = process_index(args.dirname, utfindex)
    dir = HtmlDir.find_by_path(thedir)
    p = dir.person
    unless p.nil?
      p.toc = new_toc
      p.save!
    end
  rescue
    puts "bad encoding. Run\n\nrake badchar[full_path_to_offending_file]\n\n to find what doesn't convert well."
  end
end

def process_index(dirname, blob)
  debugger
  m = blob.match(/<body.*?>/)
  die("can't understand this file structure!") if m.nil?
  body = $'.gsub(/<a(.*?)>(.*?)<\/a>/m,"[[a \\1]]\\2[[/a]]") # replace all links with placeholders
  body = body.gsub(/<.*?>/m,'') # remove all remaining HTML tags
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

  # TEMP DEBUG
  File.open('dbg_ingest.txt','w') {|f| f.puts(linked_body) }
  die("done for now")

  toc = Toc.new(toc: linked_body, status: 'Raw')
  toc.save
  return toc
end

def match_link(dirname, target, text)
  return '' if target.strip[0..3] == 'name'
  m = target.match(/href="(.*)"/)
  return '' if m.nil?
  url = $1
  return '' if ['index.html','/'].includes?(url)
  h = HtmlFile.where(url: "#{dirname}/#{url}")
  if h.nil?
    puts "ERROR: can't find HtmlFile for url #{dirname}/#{url}"
    return "ERROR: #{text} ----> #{target}\n"
  end
  thefile = h[0]
  if thefile.manifestations.empty?
    the_id = "HF#{thefile.id}"
  else
    the_id = "M#{thefile.manifestations[0].id}"
  end
  return "&&&LINK: #{the_id} &&&TEXT: #{text.strip.gsub("\n",'')}"
end

def die(msg)
  puts msg
  exit
end
