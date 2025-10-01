# frozen_string_literal: true

class ChangeReadingListsEncoding < ActiveRecord::Migration[8.0]
  def change
    execute 'ALTER TABLE reading_lists CHARACTER SET "utf8mb4" COLLATE "utf8mb4_bin"'
    execute 'ALTER TABLE reading_lists MODIFY title varchar(255) CHARACTER SET "utf8mb4" COLLATE "utf8mb4_bin"'
  end
end
