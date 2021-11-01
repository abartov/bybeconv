class MakeIdInApiKeyAutoincremental < ActiveRecord::Migration[5.2]
  def change
    change_column :api_keys, :id, :integer, auto_increment: true
  end
end
