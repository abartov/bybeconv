class AddTaskApiKeyToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tasks_api_key, :string
  end
end
