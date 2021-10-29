class AddIndexesToExpressionsManifestations < ActiveRecord::Migration[4.2]
  def change
    add_index :expressions_manifestations, :expression_id
    add_index :expressions_manifestations, :manifestation_id
  end
end
