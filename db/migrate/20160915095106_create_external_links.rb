class CreateExternalLinks < ActiveRecord::Migration
  def change
    create_table :external_links do |t|
      t.string :url
      t.string :linktype
      t.integer :status

      t.timestamps
    end
  end
end
