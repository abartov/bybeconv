# frozen_string_literal: true

class RenamePeopleToAuthorities < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :featured_authors, :people
    rename_table :people, :authorities

    rename_column :involved_authorities, :person_id, :authority_id
    rename_column :featured_contents, :person_id, :authority_id
    rename_column :publications, :person_id, :authority_id
    rename_column :html_files, :person_id, :author_id

    execute "update aboutnesses set aboutable_type = 'Authority' where aboutable_type = 'Person'"
    execute "update external_links set linkable_type = 'Authority' where linkable_type = 'Person'"
    execute "update taggings set taggable_type = 'Authority' where taggable_type = 'Person'"

    create_table :people, id: :integer do |t|
      t.integer :period
      t.string :birthdate
      t.string :deathdate
      t.integer :gender
    end

    execute <<~SQL
      insert into people (id, period, birthdate, deathdate, gender)
      select id, period, birthdate, deathdate, gender from authorities
    SQL

    add_belongs_to :authorities, :person, null: true, type: :integer, index: { unique: true }, foreign_key: true

    # At this point people.id matches id in authorities table so we can set values as follows
    # But in future there will be differences
    execute 'update authorities set person_id = id'

    remove_columns :authorities, :period, :birthdate, :deathdate, :gender

    add_foreign_key :featured_authors, :people
  end
end
