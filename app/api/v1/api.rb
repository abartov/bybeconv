Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

class V1::Api < Grape::API
  PAGE_SIZE = 25

  version :v1, using: :path
  content_type :json, 'application/json'
  default_format :json

  prefix :api

  helpers do
    params :key_param do
      requires :key, type: String, v1_auth_key: true
    end

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

    params :paging_params do
      requires :page, type: Integer, minimum_value: 1
      optional :sort_by, type: String, default: 'alphabetical', values: SortedManifestations::SORTING_PROPERTIES.keys
      optional :sort_dir, type: String, default: 'default', values: SortedManifestations::DIRECTIONS
    end
  end

  resource :search do
    params do
      use :key_param
      use :text_params
      use :paging_params
      optional :genres, type: Array[String], values: Work::GENRES, desc: 'the broad field of humanities of a textual work in the database.'
      optional :periods, type: Array[String], values: Expression.periods.keys, desc: 'specifies what section of the rough timeline of Hebrew literature an object belongs to.'
      optional :is_copyrighted, type: Boolean, desc: 'limit search to copyrighted works or to non-copyrighted works'
      optional :author_genders, type: Array[String], values: Person.genders.keys
      optional :translator_genders, type: Array[String], values: Person.genders.keys
      optional :title, type: String, desc: "a substring to match against a text's title"
      optional :author, type: String, desc: "a substring to match against the name(s) of a text's author(s)"
      optional :author_ids, type: Array[Integer]
      optional :original_language, type: String, desc: "ISO code of language, e.g. 'pl' for Polish, 'grc' for ancient Greek. Use magic constant 'xlat' to match all non-Hebrew languages"
      optional :uploaded_between, type: Array[Integer], length: 2, desc: 'pass an array of years [min_year, max_year] to get works uploaded to the site at year min_year <= year <= max_year'
      optional :created_between, type: Array[Integer], length: 2, desc: 'pass an array of years [min_year, max_year] to get works created at year min_year <= year <= max_year'
      optional :published_between, type: Array[Integer], length: 2, desc: 'pass an array of years [min_year, max_year] to get works published in print at year min_year <= year <= max_year'
    end

    get do
      page = params[:page]
      filters = params.slice(*%w(genres periods is_copyrighted author_genders translator_genders title author author_ids original_language uploaded_between created_between published_between))
      records = SearchManifestations.call(params[:sort_by], params[:sort_dir], filters)
      model = { data: records.limit(PAGE_SIZE).offset((page - 1) * PAGE_SIZE).to_a, total_count: records.count }
      present model, with: V1::Entities::ManifestationsPage, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
    end
  end

  params do
    use :key_param
  end
  resources :texts do
    desc 'Retrieve a specified page from the list of all texts'
    params do
      use :paging_params
      use :text_params
    end
    get do
      page = params[:page]
      records = SortedManifestations.call(params[:sort_by], params[:sort_dir]).all_published.limit(PAGE_SIZE).offset((page - 1) * PAGE_SIZE)
      model = { data: records, total_count: Manifestation.all_published.count }
      present model, with: V1::Entities::ManifestationsPage, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
    end

    resource :batch do
      desc 'Retrieve a collection of texts by specified IDs'
      params do
        requires :ids, type: Array[Integer], maximum_length: 25, allow_blank: false, desc: 'array of text IDs to fetch', documentation: { param_type: 'query' }
        use :text_params
      end
      get do
        ids = params[:ids]
        records = Manifestation.all_published.find(ids)
        present records, with: V1::Entities::Manifestation, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
      end
    end

    route_param :id do
      desc 'Return text by id' do
        success V1::Entities::Manifestation
      end
      params do
        requires :id, type: Integer, desc: 'Text ID'
        use :text_params
      end
      get do
        record = Manifestation.all_published.find(params[:id])
        present record, with: V1::Entities::Manifestation, view: params[:view], file_format: params[:file_format], snippet: params[:snippet]
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    model = e.model == 'Manifestation' ? "Text" : e.model
    if e.id.is_a? Array
      message = "Couldn't find one or more #{model.pluralize} with '#{e.primary_key}'=#{e.id}"
    else
      message = "Couldn't find #{model} with '#{e.primary_key}'=#{e.id}"
    end

    error!(message, 404)
  end

  rescue_from V1::Validations::AuthKey::AuthFailed do |e|
    # Returning unauthorized status
    error!(e.message, 401)
  end

  add_swagger_documentation info: { title: 'Bybeconv public API', version: '1.0.0' }
end
