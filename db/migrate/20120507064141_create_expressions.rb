class CreateExpressions < ActiveRecord::Migration
  def change
    create_table :expressions do |t|
      t.string :title
      t.string :form
      t.string :date
      t.string :language
      t.tinytext :comment

      t.timestamps
    end
  end
end
