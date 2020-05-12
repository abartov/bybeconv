class CreateDownloadables < ActiveRecord::Migration[5.2]
  def change
    create_table :downloadables do |t|
      t.references :object, polymorphic: true
      t.integer :doctype
      t.integer :status

      t.timestamps
    end
  end
end
