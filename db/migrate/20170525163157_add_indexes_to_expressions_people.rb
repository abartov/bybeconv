class AddIndexesToExpressionsPeople < ActiveRecord::Migration
  def change
    add_index :expressions_people, :person_id
    add_index :expressions_people, :expression_id
  end
end
