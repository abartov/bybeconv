class AddSourceEditionToExpression < ActiveRecord::Migration[4.2]
  def change
    add_column :expressions, :source_edition, :string
  end
end
