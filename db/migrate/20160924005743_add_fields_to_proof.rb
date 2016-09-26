class AddFieldsToProof < ActiveRecord::Migration
  def change
    add_column :proofs, :highlight, :text
    add_column :proofs, :reported_by, :integer
    add_column :proofs, :manifestation_id, :integer
  end
end
