# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    transient do
      record { create(:authority) }
    end

    visit { create(:ahoy_visit, started_at: time - 10.seconds) }
    name { Ahoy::Visit::ALLOWED_NAMES.sample }
    time { Time.now - Random.rand(240).minutes }
    properties { { id: record.id, type: record.class.name } }
  end
end
