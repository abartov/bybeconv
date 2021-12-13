class V1::TextsAPI < V1::ApplicationApi
  PAGE_SIZE = 25

  helpers do
    params :text_params do
      optional :view, type: String, default: 'basic', values: %w(metadata basic enriched), desc: <<~DESC
        how much detail to return:
          `metadata` returns all metadata and download link;
          `basic` returns basic metadata and a download_link, and is the default;
          `enriched` returns all metadata as well as tags, recommendations, external links, and aboutnesses
      DESC

      optional :file_format, type: String, default: 'html', values: %w(html txt pdf epub mobi docx odt), desc: <<~DESC
        desired text format for download link:
          `html` for HTML,
          `txt` for plain text without any formatting,
          `pdf` for PDF,
          `epub` for EPUB,
          `mobi` for MOBI,
          `docx` for DOCX,
          `odt` for LibreOffice ODT'
      DESC

      optional :snippet, type: Boolean, default: false, desc: <<~DESC
        whether or not to include a plaintext snippet of the beginning of the text.
      DESC
    end
  end

  params do
    use :key_param
  end
  resources :texts do
    resource :batch do
      desc 'Retrieve a collection of texts by specified IDs'
      params do
        requires :ids, type: Array[Integer], maximum_length: 25, allow_blank: false, desc: 'array of text IDs to fetch', documentation: { param_type: 'body' }
        use :text_params
      end
      post do
        ids = params[:ids]
        records = ManifestationsIndex.find(ids)
        # sorting result in same order as their ids are passed in parameter
        records.sort_by! { |rec| ids.find_index(rec.id) }
        present records, with: V1::Entities::ManifestationIndex, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
      end
    end

    route_param :id do
      desc 'Return text by id' do
        success V1::Entities::ManifestationIndex
      end
      params do
        requires :id, type: Integer, desc: 'Text ID'
        use :text_params
      end
      get do
        record = ManifestationsIndex.find(params[:id])
        present record, with: V1::Entities::ManifestationIndex, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
      end
    end
  end

  resource :search do
    params do
      use :key_param
      use :text_params

      requires :page, type: Integer, minimum_value: 1
      optional :sort_by, type: String, default: 'alphabetical', values: SearchManifestations::SORTING_PROPERTIES.keys
      optional :sort_dir, type: String, default: 'default', values: SearchManifestations::DIRECTIONS

      optional :genres, type: Array[String], values: Work::GENRES, desc: 'the broad field of humanities of a textual work in the database.',
               documentation: { param_type: 'body' }
      optional :periods, type: Array[String], values: Expression.periods.keys, desc: 'specifies what section of the rough timeline of Hebrew literature an object belongs to.'
      optional :is_copyrighted, type: Boolean, desc: 'limit search to copyrighted works or to non-copyrighted works'
      optional :author_genders, type: Array[String], values: Person.genders.keys
      optional :translator_genders, type: Array[String], values: Person.genders.keys
      optional :title, type: String, desc: "a substring to match against a text's title"
      optional :author, type: String, desc: "a substring to match against the name(s) of a text's author(s)"
      optional :fulltext, type: String, desc: "a substring to match against the work's full text (NOTE: if provided it will enforce result ordering by relevance)"
      optional :author_ids, type: Array[Integer]
      optional :original_language, type: String, desc: "ISO code of language, e.g. 'pl' for Polish, 'grc' for ancient Greek. Use magic constant 'xlat' to match all non-Hebrew languages"

      optional :uploaded_between, type: JSON, desc: 'pass an years interval json `{ from: min_year, to: max_year}` to get works uploaded to the site at year min_year <= year <= max_year' do
        optional :from, type: Integer
        optional :to, type: Integer
      end
      optional :created_between, type: JSON, desc: 'pass an years interval json `{ from: min_year, to: max_year}` to get works created at year min_year <= year <= max_year' do
        optional :from, type: Integer
        optional :to, type: Integer
      end
      optional :published_between, type: JSON, desc: 'pass an years interval json `{ from: min_year, to: max_year}` to get works published in print at year min_year <= year <= max_year' do
        optional :from, type: Integer
        optional :to, type: Integer
      end
    end

    post do
      page = params[:page]
      filters = params.slice(*%w(genres periods is_copyrighted author_genders translator_genders title author fulltext author_ids original_language uploaded_between created_between published_between))
      if filters['fulltext'].present?
        sort_by = nil
        sort_dir = nil
      else
        sort_by = params[:sort_by]
        sort_dir = params[:sort_dir]
      end
      records = SearchManifestations.call(sort_by, sort_dir, filters)
      model = { data: records.limit(PAGE_SIZE).offset((page - 1) * PAGE_SIZE).to_a, total_count: records.count }
      present model, with: V1::Entities::ManifestationsPage, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
    end
  end
end