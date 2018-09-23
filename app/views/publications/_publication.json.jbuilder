json.extract! publication, :id, :title, :author_line, :publisher_line, :pub_year, :language, :notes, :bib_source, :source_id, :person_id, :status, :created_at, :updated_at
json.url publication_url(publication, format: :json)
