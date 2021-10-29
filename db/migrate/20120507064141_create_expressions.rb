class CreateExpressions < ActiveRecord::Migration[4.2]
  def change
    create_table :expressions do |t|
      t.string :title
      t.string :form
      t.string :date
      t.string :language
      t.text :comment

      t.timestamps
    end
  end
end
