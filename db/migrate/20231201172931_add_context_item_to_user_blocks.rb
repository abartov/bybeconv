class AddContextItemToUserBlocks < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_blocks, :context_item, polymorphic: true
  end
end
