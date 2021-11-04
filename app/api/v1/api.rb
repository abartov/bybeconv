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
    requires :key, type: String, allow_blank: false, v1_auth_key: true
  end
  resources :texts do
    desc 'Return text by id'
    params do
      requires :id, type: Integer, desc: 'Text ID'
      use :text_params
    end
    route_param :id do
      get do
        present Manifestation.find(params[:id]), with: V1::Entities::Manifestation, view: params[:view], file_format: params[:file_format]
      end
    end
  end
end
