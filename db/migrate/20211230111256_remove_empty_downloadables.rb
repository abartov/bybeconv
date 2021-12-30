class RemoveEmptyDownloadables < ActiveRecord::Migration[5.2]
  def change
    execute <<~SQL
      delete from downloadables
      where
        object_type = 'Manifestation'
        and not exists (
          select 1 from
            active_storage_attachments a 
          where
            a.record_id = downloadables.id
            and a.record_type = 'Downloadable'
        )
    SQL
  end
end
