require 'rails_helper'

RSpec.describe BaseUser do
  describe 'validation' do
    context 'when session_id and no user_id are provided' do
      let(:subject) { build(:base_user, session_id: '123') }
      it { is_expected.to be_valid }
    end

    context 'when user_id and no session_id are provided' do
      let(:subject) { build(:base_user, user: create(:user)) }
      it { is_expected.to be_valid }
    end

    context 'when both session_id and user_id are provided' do
      let(:subject) { build(:base_user, user: create(:user), session_id: '123') }
      it { is_expected.to_not be_valid }
    end

    context 'when nor session_id nor user_id are provided' do
      let(:subject) { build(:base_user) }
      it { is_expected.to_not be_valid }
    end
  end
end
