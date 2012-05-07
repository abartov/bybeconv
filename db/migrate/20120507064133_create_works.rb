class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title
      t.string :form
      t.string :date
      t.tinytext :comment

      t.timestamps
    end
  end
end
