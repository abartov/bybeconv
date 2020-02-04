class CreateSitenotices < ActiveRecord::Migration[5.2]
  def change
    create_table :sitenotices do |t|
      t.string :body
      t.datetime :fromdate
      t.datetime :todate
      t.integer :status

      t.timestamps
    end
    add_index :sitenotices, :fromdate
    add_index :sitenotices, :todate
    add_index :sitenotices, :status
  end
end
