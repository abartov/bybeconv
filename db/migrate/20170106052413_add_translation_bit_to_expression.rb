class AddTranslationBitToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :translation, :boolean
  end
end
