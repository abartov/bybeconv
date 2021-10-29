class CreateHtmlDirs < ActiveRecord::Migration[4.2]
  def change
    create_table :html_dirs do |t|
      t.string :path
      t.string :author

      t.timestamps
    end
  end
end
