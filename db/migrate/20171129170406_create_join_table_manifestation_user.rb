class CreateJoinTableManifestationUser < ActiveRecord::Migration[4.2]
  def change
    create_join_table :Manifestations, :Users, table_name: 'work_likes' do |t|
      t.index [:manifestation_id, :user_id]
      t.index [:user_id, :manifestation_id]
    end
  end
end
