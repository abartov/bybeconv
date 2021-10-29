class AddIndexesToExpressionsWorks < ActiveRecord::Migration[4.2]
  def change
    add_index :expressions_works, :expression_id
    add_index :expressions_works, :work_id
  end
end
