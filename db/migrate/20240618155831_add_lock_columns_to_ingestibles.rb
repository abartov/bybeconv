# frozen_string_literal: true

class AddLockColumnsToIngestibles < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :ingestibles, :locked_by_user,
                   foreign_key: { to_table: :users}, type: :integer, index: true, null: true

    add_column :ingestibles, :locked_at, :timestamp, null: true
  end
end
