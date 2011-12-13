class HtmlFile < ActiveRecord::Base

  def analyze
    # Word footnotes magic word 'mso-footnote-id'
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
  end

end
