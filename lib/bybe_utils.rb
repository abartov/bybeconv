module BybeUtils
  # return a hash like {:total => total_number_of_non_tags_characters, :nikkud => total_number_of_nikkud_characters, :ratio => :nikkud/:total }
  def count_nikkud(text)
    info = { :total => 0, :nikkud => 0, :ratio => nil }
    ignore = false
    text.each_char {|c|
      if c == '<'
        ignore = true
      elsif c == '>'
        ignore = false
        next
      end
      unless ignore or c.match /\s/ # ignore tags and whitespace
        info[:nikkud] += 1 if ["\u05B0","\u05B1","\u05B2","\u05B3","\u05B4","\u05B5","\u05B6","\u05B7","\u05B8","\u05B9","\u05BB","\u05BC","\u05C1","\u05C2"].include? c
        info[:total] += 1
      end
    }
    info[:total] -= 35 # rough compensation for text of index and main page links, to mitigate ratio problem for very short texts
    info[:ratio] = info[:nikkud].to_f / info[:total]
    puts "DBG: total #{info[:total]} - nikkud #{info[:nikkud]} - ratio #{info[:ratio]}"
    return info
  end
  # retrieve author name for (relative) directory name d, using provided hash known_authors to cache results
  def author_name_from_dir(d, known_authors)
    if known_authors[d].nil?
      thedir = HtmlDir.find_by_path(d)
      if thedir.nil?
        thedir = HtmlDir.new(:path => d, :author => "__edit__#{d}")
        thedir.save! # to be filled later
      end
      known_authors[d] = thedir.author.force_encoding('utf-8')
    end
    return known_authors[d]
  end

  def fix_encoding(buf)
    newbuf = buf.force_encoding('windows-1255')
        ENCODING_SUBSTS.each { |s|
          newbuf.gsub!(s[:from].force_encoding('windows-1255'), s[:to])
        }
    return newbuf
  end
  def is_blacklisted_ip(ip)
    # check posting IP against HTTP:BL
    unless AppConstants.project_honeypot_api_key.nil?
      listing = ProjectHoneypot.lookup(AppConstants.project_honeypot_api_key, ip)
      return true if listing.comment_spammer? or listing.suspicious? # silently ignore spam submissions
    end
    return false  
  end
end
