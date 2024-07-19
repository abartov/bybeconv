# frozen_string_literal: true

class AddUncollectedWorksCollectionIdToAuthorities < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :authorities, :uncollected_works_collection,
                   foreign_key: { to_table: :collections}, index: { unique: true }, type: :integer

  end
end
