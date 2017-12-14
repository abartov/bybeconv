class FixTocStatus < ActiveRecord::Migration
  def change
    puts "fixing nil TOC status fields"
    Person.has_toc.each do |p|
      if p.toc.status.nil?
        p.toc.status = 'raw'
        p.toc.save!
      end
    end
  end
end
