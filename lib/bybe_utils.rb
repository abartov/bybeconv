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
        info[:nikkud] += 1 if text.is_nikkud(c)
        info[:total] += 1
      end
    }
    if text.length < 200 and text.length > 50
      info[:total] -= 35 # rough compensation for text of index and main page links, to mitigate ratio problem for very short texts
    end
    info[:ratio] = info[:nikkud].to_f / info[:total]
#    puts "DBG: total #{info[:total]} - nikkud #{info[:nikkud]} - ratio #{info[:ratio]}"
    return info
  end

  # just return a boolean if the buffer is "full" nikkud
  def full_nikkud(text)
    info = count_nikkud(text)
    false || (info[:total] > 1000 and info[:ratio] > 0.5) || (info[:total] <= 1000 and info[:ratio] > 0.3)
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
      if listing.comment_spammer? or listing.suspicious? # silently ignore spam submissions
        logger.info "SPAM IP identified by HTTP:BL lookup.  Ignoring form submission."
        return true 
      end
    end
    return false  
  end
  def client_ip
    #logger.debug "client_ip - request.env dump follows\n#{request.env.to_s}"
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end
  def remove_payload(buf)
    m = buf.match(/<!-- begin BY head -->/)
    return buf if m.nil? # though, seriously?
    tmpbuf = $`
    m = buf.match(/<!-- end BY head -->/)
    tmpbuf += $'
    m = tmpbuf.match(/<!-- begin BY body -->/)
    newbuf = $`
    m = tmpbuf.match(/<!-- end BY body -->/)
    newbuf += $'
    return newbuf
  end
  def remove_toc_links(buf)
    return buf.gsub(/<a\s+?href="index.html">.*?<\/a>/mi, '').gsub(/<a\s+?href="\/">.*?<\/a>/mi,'').gsub(/<a\s+?href="http:\/\/benyehuda.org\/"/mi,'')
  end
  def remove_prose_table(buf)
    buf =~ /<table.*? width="70%".*?>.*?<td.*?>(.*)<\/td>.*?<\/table>/im # if prose table exists, grab its contents
    return buf if $1 == nil
    return $` + $1 + $'
  end
end
