class AddTranslationBitToExpression < ActiveRecord::Migration[4.2]
  def change
    add_column :expressions, :translation, :boolean
  end
end
