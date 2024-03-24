class AddVidScopeToBibSource < ActiveRecord::Migration[6.1]
  def change
    add_column :bib_sources, :vid, :string unless column_exists? :bib_sources, :vid
    add_column :bib_sources, :scope, :string unless column_exists? :bib_sources, :scope
  end
end
