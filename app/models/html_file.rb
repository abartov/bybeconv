class HtmlFile < ActiveRecord::Base

  def analyze
  
    # Word footnotes magic word 'mso-footnote-id'
    html = File.open(self.path, "r:windows-1255:UTF-8").read
    #html = File.open(self.path, "r:ISO-8859-8:UTF-8").read
    if html =~ /mso-footnote-id/
      self.footnotes = true
    end
    print "Analysis results -- footnotes: #{self.footnotes}, images: #{self.images}, tables: #{self.tables}\n"
    self.save!
    # Word tables magic word (beyond the basic BY formatting table for prose!): 
    # Word images magic word: 
  end

end
