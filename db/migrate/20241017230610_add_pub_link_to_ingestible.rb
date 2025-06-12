# frozen_string_literal: true

class AddPubLinkToIngestible < ActiveRecord::Migration[6.1]
  def change
    change_column :ingestibles, :pub_link, :string, limit: 2048
    change_column :ingestibles, :pub_link_text, :string, limit: 1024
  end
end
