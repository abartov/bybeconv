class AddCrowdsourcerToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :crowdsourcer, :boolean
  end
end
