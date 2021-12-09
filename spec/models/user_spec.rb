require 'rails_helper'

describe User do
  it "consider invalid an empty user" do
    u = User.new
    expect(u).to_not be_valid
  end

  it 'consider valid user with minimal attributes set' do
    u = User.new(name: Faker::Artist.name, email: Faker::Internet.email, provider: 'developer')
    expect(u).to be_valid
  end

  it 'validates email' do
    u = User.new(name: Faker::Artist.name, email: 'wrong_email', provider: 'developer')
    expect(u).to_not be_valid
  end

  context 'when user with same email already exists' do
    let(:other_user) { create(:user) }
    it 'consider user with duplicate email invalid' do
      u = User.new(name: Faker::Artist.name, email: other_user.email, provider: 'developer')
      expect(u).to_not be_valid
    end
  end

  describe 'has_bit?' do
    let(:user) { create(:user, editor: true) }

    context 'when no list_items exists for user' do
      it "doesn't have any bits" do
        expect(user.has_bit?('test_bit')).to be_falsey
        expect(user.has_bit?('other_bit')).to be_falsey
      end
    end

    context "when list item with 'test_bit' key exists" do
      before do
        create(:list_item, listkey: 'test_bit', item: user)
      end
      it "returns true for it" do
        expect(user.has_bit?('test_bit')).to be_truthy
        expect(user.has_bit?('other_bit')).to be_falsey
      end
    end

    context "when list item with 'other_bit' key exists" do
      before do
        create(:list_item, listkey: 'other_bit', item: user)
      end
      it "returns true for it" do
        expect(user.has_bit?('test_bit')).to be_falsey
        expect(user.has_bit?('other_bit')).to be_truthy
      end
    end

    context "when two list items exists" do
      before do
        create(:list_item, listkey: 'test_bit', item: user)
        create(:list_item, listkey: 'other_bit', item: user)
      end
      it "returns true for both" do
        expect(user.has_bit?('test_bit')).to be_truthy
        expect(user.has_bit?('other_bit')).to be_truthy
      end
    end
  end
end