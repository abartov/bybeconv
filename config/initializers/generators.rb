# frozen_string_literal: true

if Rails.env.development?
  # disabling some Rails generators to avoid creation of unnecessary files during controller/resources creation
  Rails.application.configure do
    config.generators do |g|
      g.assets false
      g.helper false
      g.stylesheets false

      g.test_framework :rspec,
                       view_specs: false,
                       request_specs: true,
                       routing_specs: false,
                       controller_specs: false
    end
  end
end
