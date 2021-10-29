class AddCopyrightToExpression < ActiveRecord::Migration[4.2]
  def change
    add_column :expressions, :copyrighted, :boolean
    add_column :expressions, :copyright_expiration, :date
  end
end
