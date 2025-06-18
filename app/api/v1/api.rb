# frozen_string_literal: true

Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

module V1
  # Rest API v1
  class Api < ApplicationApi
    version :v1, using: :path
    content_type :json, 'application/json'
    default_format :json

    prefix :api

    mount TextsApi => '/'
    mount AuthoritiesApi => '/'

    add_swagger_documentation info: { title: 'Project Ben-Yehuda public API' }, doc_version: '1.2.0'
  end
end
