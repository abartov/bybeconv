require 'rails_helper'

describe ApiKey do
  it 'normalizes email before validation' do
    key = ApiKey.new(email: '  Test@test.com    ')
    key.valid?
    expect(key.email).to eq 'test@test.com'
  end
end