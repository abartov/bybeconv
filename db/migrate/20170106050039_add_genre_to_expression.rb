class AddGenreToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :genre, :string
  end
end
