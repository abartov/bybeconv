Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

class V1::Api < V1::ApplicationApi
  version :v1, using: :path
  content_type :json, 'application/json'
  default_format :json

  prefix :api

  mount V1::TextsAPI => '/'
  mount V1::PeopleAPI => '/'

  add_swagger_documentation info: { title: 'Bybeconv public API', version: '1.0.0' }
end
