Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

class V1::Api < Grape::API
  version :v1, using: :path
  content_type :json, 'application/json'
  default_format :json

  prefix :api
  # add_swagger_documentation info: { title: 'Bybeconv public API', version: '0.0.1' }

  helpers do
    params :text_params do
      optional :view, type: String, default: 'basic', values: %w(metadata basic), desc: <<~DESC
        how much detail to return:
          `metadata` returns all metadata and download_link but no smippet of the text;
          `basic` returns basic metadata, download_link. a snippet of the beginning of the text, and is the default
      DESC

      optional :file_format, type: String, default: 'html', values: %w(html txt pdf epub mobi docx odt), desc: <<~DESC
        desired text format:
          `html` for HTML,
          `txt` for plain text without any formatting,
          `pdf` for PDF,
          `epub` for EPUB,
          `mobi` for MOBI,
          `docx` for DOCX,
          `odt` for LibreOffice ODT'
      DESC
    end
  end

  params do
    requires :key, type: String, v1_auth_key: true
  end
  resources :texts do
    resource :batch do
      desc 'Retrieve a collection of texts by specified IDs'
      params do
        requires :ids, type: Array[Integer], allow_blank: false, desc: 'array of text IDs to fetch'
        use :text_params
      end
      get do
        ids = params[:ids]
        if ids.size > 25
          error!('Couldn\'t request more that 25 IDs per batch', 400)
          return
        end
        records = Manifestation.all_published.find(ids)
        present records, with: V1::Entities::Manifestation, view: params[:view], file_format: params[:file_format]
      end
    end

    route_param :id do
      desc 'Return text by id'
      params do
        requires :id, type: Integer, desc: 'Text ID'
        use :text_params
      end
      get do
        record = Manifestation.all_published.find(params[:id])
        present record, with: V1::Entities::Manifestation, view: params[:view], file_format: params[:file_format]
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
end
