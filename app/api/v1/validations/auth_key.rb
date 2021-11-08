class V1::Validations::AuthKey < Grape::Validations::Base
  def validate_param!(attr_name, params)
    key = params[attr_name]
    api_key = ApiKey.find_by(key: key)
    if api_key.nil? || api_key.status_disabled?
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'not found or disabled'
    end
  end
end
