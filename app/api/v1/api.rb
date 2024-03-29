Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

class V1::Api < V1::ApplicationApi
  version :v1, using: :path
  content_type :json, 'application/json'
  default_format :json

  prefix :api

  mount V1::TextsAPI => '/'
  mount V1::PeopleAPI => '/'

  add_swagger_documentation info: { title: 'Project Ben-Yehuda public API' }, doc_version: '1.1.0'
end
