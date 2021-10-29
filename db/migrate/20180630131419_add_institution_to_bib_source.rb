class AddInstitutionToBibSource < ActiveRecord::Migration[4.2]
  def change
    add_column :bib_sources, :institution, :string
  end
end
