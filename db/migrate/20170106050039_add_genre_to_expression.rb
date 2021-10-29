class AddGenreToExpression < ActiveRecord::Migration[4.2]
  def change
    add_column :expressions, :genre, :string
  end
end
