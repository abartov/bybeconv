class HtmlFile < ActiveRecord::Base

  def analyze
    # Word footnotes magic word 'mso-footnote-id'
    begin
      html = File.open(self.path, "r:windows-1255:UTF-8").read
      self.footnotes = (html =~ /mso-footnote-id/) ? true : false
      # Word images magic word: '<img'
      self.images = (html =~ /<img/) ? true : false
      # Word tables magic word (beyond the basic BY formatting table for prose!):
      buf = html
      self.tables = false # unless proven otherwise below
      while buf =~ /<table[^>]*>/ do
        # ignore the Ben-Yehuda standard prose 70% table
        thematch = $~.to_s
        if thematch !~ /<table[^>]*width=\"70%\"[^>]*>/
          self.tables = true
        end
        buf = $' # postmatch
      end
      # debugging # print "Analysis results -- footnotes: #{self.footnotes}, images: #{self.images}, tables: #{self.tables}\n"
      self.status = 'Analyzed' if self.status == 'Unknown' 
      self.save!
    rescue 
      print "error: #{$!}\n"
      if $!.to_s =~ /conversion/
        print "match!"
        self.status = 'BadCP1255'
      else
        print "no match?! err = #{$!}\n"
        self.status = 'FileError'
      end
      self.save!
    end
  end
  def self.analyze_all # class method
    HtmlFile.find_all_by_status('Unknown').each { |h| h.analyze }
  end
  def fix_encoding
    if self.status == 'BadCP1255'
      raw = IO.binread(self.path)
      raw.gsub!("\xCA","\xC9") # fix weird invalid chars instead of proper Hebrew xolams
      newfile = self.path + '.fixed_encoding'
      # IO.binwrite(newfile, raw) # this works only on Ruby 1.9.3+
      File.open(newfile, 'wb') {|f| f.write(raw) } # works on any modern Ruby
      begin
        html = File.open(newfile, "r:windows-1255:UTF-8").read
        # yay! The file is now valid and converts fine to UTF-8! :)
        print "Success! #{newfile} is valid!  Please replace the live file #{self.path} with #{newfile} manually, for safety." 
        self.status = 'Unknown' # so that this file gets re-analyzed after the manual copy
        self.save!
      rescue
        print "fix_encoding replaced 0xCA with 0xC9 but fixed file #{newfile} is still unreadable!  Error: #{$!}\n" # debug
      end
    else
      print 'fix_encoding called but status doesn''t indicate BadCP1255... Ignoring.' # debug
    end
  end
end
