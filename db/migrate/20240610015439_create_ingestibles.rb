class CreateIngestibles < ActiveRecord::Migration[6.1]
  def change
    drop_table :ingestibles if table_exists?(:ingestibles)
    create_table :ingestibles do |t|
      t.string :title
      t.integer :status
      t.integer :scenario
      t.text :default_authorities
      t.text :metadata
      t.text :comments
      t.text :markdown
      t.integer :user_id
      t.string :problem
      t.string :orig_lang
      t.string :year_published
      t.string :genre
      t.string :publisher
      t.string :pub_link
      t.string :pub_link_text
      t.boolean :attach_photos, null: false, default: false
      t.boolean :no_volume, null: false, default: false
      t.text :toc_buffer, limit: 50_000
      t.integer :volume_id
      t.text :works_buffer, limit: 16_000_000
      t.datetime :markdown_updated_at
      t.datetime :works_buffer_updated_at
      t.timestamps
    end

    add_index :ingestibles, :volume_id
    add_index :ingestibles, :title
    add_index :ingestibles, :status
    add_index :ingestibles, :user_id
  end
end
