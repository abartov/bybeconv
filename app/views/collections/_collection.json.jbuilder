json.extract! collection, :id, :title, :sort_title, :subtitle, :issn, :collection_type, :inception, :inception_year, :publication_id, :toc_id, :toc_strategy, :created_at, :updated_at
json.url collection_url(collection, format: :json)
