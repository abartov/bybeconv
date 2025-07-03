# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    visit { create(:ahoy_visit, started_at: time - 10.seconds) }
    name { Ahoy::Event::ALLOWED_NAMES.sample }
    time { Time.now - Random.rand(240).minutes }

    transient do
      controller { 'welcome' }
      action { 'index' }
    end

    properties { { controller: controller, action: action } }

    trait :with_item do
      transient do
        item { create(:authority) }
      end

      controller { item.class.name.pluralize }
      action { name }

      properties do
        { id: item.id, type: item.class.name, controller: controller, action: action }
      end
    end
  end
end
