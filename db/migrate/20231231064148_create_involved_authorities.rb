class CreateInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    create_table :involved_authorities do |t|
      t.references :authority, polymorphic: true
      t.integer :role
      t.references :item, polymorphic: true

      t.timestamps
    end unless table_exists? :involved_authorities
  end
end
