class CreateWorks < ActiveRecord::Migration[4.2]
  def change
    create_table :works do |t|
      t.string :title
      t.string :form
      t.string :date
      t.text :comment

      t.timestamps
    end
  end
end
