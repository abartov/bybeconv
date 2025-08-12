# frozen_string_literal: true

# Absrtract base class for all V1 API implementations
module V1
  # Base class for application APIs v1
  class ApplicationApi < Grape::API
    helpers do
      params :key_param do
        requires :key, type: String, auth_key: true
      end
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      model = e.model == 'Manifestation' ? 'Text' : e.model
      message = if e.id.is_a? Array
                  "Couldn't find one or more #{model.pluralize} with '#{e.primary_key}'=#{e.id}"
                else
                  "Couldn't find #{model} with '#{e.primary_key}'=#{e.id}"
                end

      error!(message, 404)
    end

    rescue_from Chewy::DocumentNotFound do |e|
      error!(e.message, 404)
    end

    rescue_from V1::Validations::AuthKey::AuthFailed do |e|
      # Returning unauthorized status
      error!(e.message, 401)
    end
  end
end
