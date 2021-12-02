Grape::Validations.register_validator('v1_auth_key', V1::Validations::AuthKey)

# Absrtract base class for all V1 API implementations
class V1::ApplicationApi < Grape::API
  helpers do
    params :key_param do
      requires :key, type: String, v1_auth_key: true
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
