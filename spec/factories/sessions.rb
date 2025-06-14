# frozen_string_literal: true

FactoryBot.define do
  factory :session, class: 'ActiveRecord::SessionStore::Session' do
    session_id { SecureRandom.hex(32) }
    data { '' }
  end
end
