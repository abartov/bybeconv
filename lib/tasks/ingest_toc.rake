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
    new_toc = process_index(utfindex)
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

def process_index(blob)
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
      linked_body += match_link($1, $2)
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

def match_link(target, text)
 "LINK: #{text} ----> #{target}\n"
end

def die(msg)
  puts msg
  exit
end
