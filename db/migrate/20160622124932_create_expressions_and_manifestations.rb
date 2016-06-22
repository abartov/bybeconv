class CreateExpressionsAndManifestations < ActiveRecord::Migration
  def change
create_table :expressions_manifestations, id: false do |t|
      t.belongs_to :expression, index: true
      t.belongs_to :manifestation, index: true
    end
  end
end
