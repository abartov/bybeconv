class AddFieldsToProofs < ActiveRecord::Migration[4.2]
  def change
    add_column :proofs, :html_file_id, :integer
    add_column :proofs, :resolved_by, :integer
  end
end
