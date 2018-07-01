class AddInstitutionToBibSource < ActiveRecord::Migration
  def change
    add_column :bib_sources, :institution, :string
  end
end
