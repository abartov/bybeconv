# frozen_string_literal: true

FactoryBot.define do
  factory :ingestible do
    title { 'MyString' }
    status { 1 }
    defaults { 'MyText' }
    metadata { 'MyText' }
    comments { 'MyText' }
    markdown { 'MyText' }
  end
end
