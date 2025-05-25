# frozen_string_literal: true

class AddLastEditorToUser < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :ingestibles, :last_editor,
                   foreign_key: { to_table: :users}, type: :integer, index: true, null: true
  end
end
