#require "yaml"

desc "remove the two optional sections on all BY HTML files"
task :unbehead, [:limit] => :environment do |taskname, args|
  thedir = AppConstants.base_dir
  tot = { :dir => 0, :files => 0, :success => 0, :badenc => [], :limit => nil, :utf16 => [] }
  unless args.limit.nil?
    tot[:limit] = args.limit.to_i
  end

  # traverse tree and process all HTML files
  unbehead_traverse(thedir, tot)

  tot[:badenc].each {|f| print "#{f} has mixed encoding.\n" }
  tot[:utf16].each {|f| print "#{f} has UTF-16 I can't convert!\n" }
  print "\n#{tot[:dir]} directories containing #{tot[:files]} files scanned: #{tot[:success]} files unbeheaded, #{tot[:utf16].count} files skipped due to unconvertible UTF-16, #{tot[:badenc].count} files skipped due to mixed encoding.\n"
end

private
def unbehead_traverse(dir, t)
  t[:dir]=t[:dir]+1
  print "traversing directory ##{t[:dir]} - #{dir}                \r"
  Dir.foreach(dir) { |fname|
    break unless t[:limit].nil? or t[:files] <= t[:limit]
    thefile = dir+'/'+fname
    if !(File.directory?(thefile)) and fname =~ /\.html$/ and not fname == 'index.html' and fname !~ /_no_nikkud/ and not dir == AppConstants.base_dir 
      puts "DBG: #{thefile}"
      t[:files] += 1 
      begin
        # fugly hack
        pre_read = File.open(thefile, 'rb').read(2000)
        if pre_read =~ /windows-1252/ or pre_read =~ /ISO-8859-1/
          cp = 1252
          begin
            html = File.open(thefile, 'r:windows-1252:UTF-8').read
          rescue
            html = File.open(thefile, 'r:UTF-8').read
          end
        elsif pre_read =~ /charset=UTF-8/
          cp = 8
          html = File.open(thefile, 'r:UTF-8').read
        elsif pre_read =~ /charset=unicode/ # UTF-16!!
          cp = 8
          begin
            html = File.open(thefile, 'r:UTF-16:UTF-8').read
          rescue
            t[:utf16] << thefile
            next
          end
        else
          cp = 1255
          html = File.open(thefile, 'r:windows-1255:UTF-8').read
        end
        orig_mtime = File.mtime(thefile)
        orig_atime = File.atime(thefile)
        html = remove_font_cruft(html) # remove Word-generated useless font-face list
        if has_placeholders?(html)
          html = remove_payload(html) 
          t[:success] += 1
        end
        # keep a backup in case of catastrophe (e.g. power off) in the midst of live file update
        html.sub!('charset=windows-1252', 'charset=UTF-8')
        html.sub!('charset=ISO-8859-1', 'charset=UTF-8')
        html.sub!('charset=windows-1255', 'charset=UTF-8')
        html.sub!('charset=unicode', 'charset=UTF-8')
        wenc = 'w:UTF-8' # no matter what, we write UTF-8 files from now on!
        #wenc = 'w:windows-1255'
        File.open('behead.backup', wenc) { |f| 
          f.truncate(0)
          f.write(thefile + "\n")
          f.write(html)
        }
        # DBG File.open("/tmp/__#{thefile.sub('/','_')}", 'w:windows-1255') { |f| 
        File.open(thefile, wenc) { |f| 
          f.truncate(0)
          f.write(html) 
        }
        File.utime(orig_atime, orig_mtime, thefile) # restore (falsify, heh) previous mtime/atime to avoid throwing off date-based manual BY site updates
        # get rid of backup upon successful update.  This allows the _existence_ of the file to be a sign of trouble :)
      rescue
        puts "Bad encoding: #{thefile}"
        t[:badenc].push thefile
      end
      File.delete('behead.backup') if File.exist?('behead.backup')
    elsif File.directory?(thefile) and fname !~ /^_/ and fname !~ /[\._]files/ and fname !~ /^\./ and not AppConstants.populate_exclude.split(';').include? fname
      unbehead_traverse(thefile, t) # recurse
    end
  }
end

def has_placeholders?(buf)
  return (buf.match(/<!-- begin BY head -->/)) && (buf.match(/<!-- begin BY body -->/))
end
def remove_font_cruft(buf)
  dbg_size = buf.length
  m = buf.match(/\/\* Font Definitions \*\//)
  return buf if m.nil? 
  tmpbuf = $`
  remainder = $'
  m = remainder.match(/\/\* Style Definitions \*\//)
  tmpbuf += $& + $' # effectively skip the whole interminable font-face definitions
  dbg_newlen = tmpbuf.length
  ratio = dbg_newlen.to_f/dbg_size*100
  puts "DBG: #{dbg_size-dbg_newlen} bytes removed (now #{ratio.round(2)}%)" if ratio < 90.0
  return tmpbuf
end

