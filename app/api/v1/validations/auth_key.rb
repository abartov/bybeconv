# frozen_string_literal: true

module V1
  module Validations
    # Auth key check
    class AuthKey < Grape::Validations::Base
      class AuthFailed < StandardError; end

      def validate_param!(attr_name, params)
        key = params[attr_name]
        api_key = ApiKey.find_by(key: key) if key.present?
        return unless api_key.nil? || api_key.status_disabled?

        raise AuthFailed, "#{@scope.full_name(attr_name)} not found or disabled"
      end
    end
  end
end
