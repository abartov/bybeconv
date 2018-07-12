class Toc < ActiveRecord::Base
  is_impressionable
  attr_accessible :person_id, :status, :toc, :credits
  has_paper_trail
  enum status: [:raw, :ready]

  def refresh_links
    buf = toc
    ret = ''
    until buf.empty?
      m = buf.match /&&&\s*פריט: (.\d+)\s*&&&\s*כותרת: (.*?)&&&/
      if m.nil?
        ret += buf
        buf = ''
      else
        ret += $`
        addition = $& # by default
        buf = $'
        if $1[0] == 'ה' # linking to a legacy HtmlFile
          begin
            h = HtmlFile.find_by(id: $1[1..-1].to_i)
            unless h.nil?
              if h.status == 'Published' && h.manifestations.count > 0
                addition = "&&& פריט: מ#{h.manifestations[0].id} &&& כותרת: #{$2} &&&" # else, no manifestation yet, keep linking to the HtmlFile
              end
            end
          rescue
            puts "no such HtmlFile"
          end
        end
        ret += addition
      end
    end
    return ret
  end
end
