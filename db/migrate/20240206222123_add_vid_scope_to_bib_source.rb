class AddVidScopeToBibSource < ActiveRecord::Migration[6.1]
  def change
    add_column :bib_sources, :vid, :string
    add_column :bib_sources, :scope, :string
  end
end
