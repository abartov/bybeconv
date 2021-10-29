class AddIndexesToExpressionsPeople < ActiveRecord::Migration[4.2]
  def change
    add_index :expressions_people, :person_id
    add_index :expressions_people, :expression_id
  end
end
