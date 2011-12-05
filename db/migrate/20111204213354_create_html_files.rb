class CreateHtmlFiles < ActiveRecord::Migration
  def change
    create_table :html_files do |t|
      t.string :path
      t.string :url
      t.string :status
      t.string :problem

      t.timestamps
    end
  end
end
