class AddCopyrightToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :copyrighted, :boolean
    add_column :expressions, :copyright_expiration, :date
  end
end
