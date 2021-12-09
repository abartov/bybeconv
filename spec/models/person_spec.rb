require 'rails_helper'

describe Person do
  it 'considers empty Person invalid' do
    p = Person.new
    expect(p).to_not be_valid
  end

  it 'considers Person with only name as valid' do
    p = Person.new(name: Faker::Artist.name)
    expect(p).to be_valid
  end

end