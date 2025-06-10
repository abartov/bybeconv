# frozen_string_literal: true

Chewy.settings = {
  host: ENV.fetch('ELASTICSEARCH_HOST'),
  prefix: Rails.env.test? ? 'test' : nil
}
