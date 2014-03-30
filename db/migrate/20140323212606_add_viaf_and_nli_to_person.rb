class AddViafAndNliToPerson < ActiveRecord::Migration
  def change
    add_column :people, :viaf_id, :string
    add_column :people, :nli_id, :string
  end
end
