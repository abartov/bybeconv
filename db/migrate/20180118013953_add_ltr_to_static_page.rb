class AddLtrToStaticPage < ActiveRecord::Migration
  def change
    add_column :static_pages, :ltr, :boolean
    StaticPage.all.each{|p| p.ltr = false
      p.save!
    }
  end
end
