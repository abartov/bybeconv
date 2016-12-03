class Toc < ActiveRecord::Base
  attr_accessible :person_id, :status, :toc
  has_paper_trail

  def refresh_links
    buf = toc
    ret = ''
    until buf.empty?
      m = buf.match /&&&LINK: (\w\d+) &&&TEXT: (.*?)&&&/
      if m.nil?
        ret += buf
        buf = ''
      else
        ret += $`
        addition = $& # by default
        buf = $'
        if $1[0] == 'H' # linking to a legacy HtmlFile
          h = HtmlFile.find($1[1..-1].to_i)
          unless h.nil?
            if h.status == 'Published'
              addition = "&&&LINK: M#{h.manifestations[0].id} &&&TEXT: #{$2}&&&" # else, no manifestation yet, keep linking to the HtmlFile
            end
          end
        end
        ret += addition
      end
    end
  end
end
