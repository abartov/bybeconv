class AddViafAndNliToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :viaf_id, :string
    add_column :people, :nli_id, :string
  end
end
