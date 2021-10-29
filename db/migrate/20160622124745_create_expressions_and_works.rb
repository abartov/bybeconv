class CreateExpressionsAndWorks < ActiveRecord::Migration[4.2]
  def change
create_table :expressions_works, id: false do |t|
      t.belongs_to :expression, index: true
      t.belongs_to :work, index: true
    end
  end
end
