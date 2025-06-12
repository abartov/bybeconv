class AddIndicesToProofs < ActiveRecord::Migration[6.1]
  def change
    add_index :proofs, [:status, :created_at]
    add_index :proofs, [:status, :manifestation_id]
  end
end
