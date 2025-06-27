class DeleteProofImpressions < ActiveRecord::Migration[5.2]
  def change
    execute "delete from impressions where impressionable_type = 'Proof'"
  end
end
