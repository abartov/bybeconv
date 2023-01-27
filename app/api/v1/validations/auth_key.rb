class V1::Validations::AuthKey < Grape::Validations::Base
  class AuthFailed < StandardError;  end

  def validate_param!(attr_name, params)
    key = params[attr_name]
    api_key = ApiKey.find_by(key: key) if key.present? && !key.blank?
    if api_key.nil? || api_key.status_disabled?
      fail AuthFailed, "#{@scope.full_name(attr_name)} not found or disabled"
    end
  end
end
