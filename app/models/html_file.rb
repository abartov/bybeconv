class HtmlFile < ActiveRecord::Base

  def analyze
  
    # Word footnotes magic word 'mso-footnote-id'
    html = File.open(self.path, "r:windows-1255:UTF-8").read
    if html =~ /mso-footnote-id/
      self.footnotes = true
    end
    # Word images magic word: '<img'
    if html =~ /<img/
      self.images = true
    end
    # Word tables magic word (beyond the basic BY formatting table for prose!):
    buf = html
    while buf =~ /<table[^>]*>/ do
      # ignore the Ben-Yehuda standard prose 70% table
      thematch = $~.to_s
      if thematch !~ /<table[^>]*width=\"70%\"[^>]*>/
        self.tables = true
      end
      buf = $' # postmatch
    end
    print "Analysis results -- footnotes: #{self.footnotes}, images: #{self.images}, tables: #{self.tables}\n"
    self.save!
  end

end
