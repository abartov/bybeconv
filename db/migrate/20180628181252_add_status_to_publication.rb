class AddStatusToPublication < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :status, :integer
  end
end
