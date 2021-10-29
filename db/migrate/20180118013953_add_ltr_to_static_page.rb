class AddLtrToStaticPage < ActiveRecord::Migration[4.2]
  def change
    add_column :static_pages, :ltr, :boolean
    StaticPage.all.each{|p| p.ltr = false
      p.save!
    }
  end
end
