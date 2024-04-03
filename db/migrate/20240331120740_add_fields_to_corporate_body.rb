class AddFieldsToCorporateBody < ActiveRecord::Migration[6.1]
  def change
    add_column :corporate_bodies, :sort_name, :string unless column_exists? :corporate_bodies, :sort_name
    add_index :corporate_bodies, :sort_name unless index_exists? :corporate_bodies, :sort_name
    add_column :corporate_bodies, :country, :string unless column_exists? :corporate_bodies, :country
    add_column :corporate_bodies, :nli_id, :string unless column_exists? :corporate_bodies, :nli_id
    add_column :corporate_bodies, :wikipedia_url, :string, limit: 800 unless column_exists? :corporate_bodies, :wikipedia_url
    add_column :corporate_bodies, :wikipedia_snippet, :text, limit: 5000 unless column_exists? :corporate_bodies, :wikipedia_snippet

    add_column :corporate_bodies, :public_domain, :boolean unless column_exists? :corporate_bodies, :public_domain
    add_column :corporate_bodies, :bib_done, :boolean unless column_exists? :corporate_bodies, :bib_done
    add_column :corporate_bodies, :status, :integer unless column_exists? :corporate_bodies, :status
    add_column :corporate_bodies, :published_at, :datetime unless column_exists? :corporate_bodies, :published_at
    change_column :corporate_bodies, :alternate_names, :text, limit: 5000
  end
end
