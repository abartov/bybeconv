# frozen_string_literal: true

class RemoveSidepicImageUrlAndTitleFromPeople < ActiveRecord::Migration[6.1]
  def change
    remove_column :people, :sidepic_content_type, :string
    remove_column :people, :sidepic_file_size, :bigint
    remove_column :people, :sidepic_file_name, :string
    remove_column :people, :sidepic_updated_at, :datetime

    remove_column :people, :image_url, :string
    remove_column :people, :title, :string

    remove_column :people, :metadata_approved, :tinyint
  end
end
