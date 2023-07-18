require 'rails_helper'

RSpec.describe TagName, type: :model do
  it 'has a valid factory' do
    expect(build(:tag_name)).to be_valid
  end
  it "creates a TagName along with a Tag" do
    u = create(:user)
    tc = TagName.count
    name = Faker::Science.science
    t = Tag.new(name: name, creator: u, status: 'pending')
    t.save
    expect(TagName.last.name).to eq name
    expect(TagName.count).to eq tc + 1
  end
  
end
