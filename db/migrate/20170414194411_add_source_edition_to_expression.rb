class AddSourceEditionToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :source_edition, :string
  end
end
