class AddSefariaLinkerToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :sefaria_linker, :boolean
  end
end
