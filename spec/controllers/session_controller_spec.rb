require 'rails_helper'

describe SessionController do
  describe 'create' do
    let!(:base_user) { BaseUser.create(session_id: session.id) }

    before(:all) do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:twitter, { uid: 'UID', info: { email: 'test@test.com', name: 'Asaf' }, credentials: { token: 'TOKEN' } })
    end

    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    end

    subject { post :create }

    context 'when new User sign up' do
      it 'creates new User record and updates BaseUser' do
        expect { subject }.to change { User.count }.by(1)
        u = User.order(id: :desc).first
        expect(u).to have_attributes email: 'test@test.com', name: 'Asaf', provider: 'twitter', uid: 'UID', oauth_token: 'TOKEN'

        base_user.reload
        expect(base_user.user_id).to eq u.id
        expect(base_user.session_id).to be_nil

        expect(session['user_id']).to eq u.id
      end
    end

    context 'when existing User sign in' do
      let!(:user) { create(:user, provider: 'twitter', uid: 'UID') }
      let!(:existing_base_user) { create(:base_user, user: user) }

      it 'uses existing User record and does not updates BaseUser' do
        expect { subject }.to_not change { User.count }
        user.reload
        expect(user).to have_attributes email: 'test@test.com', name: 'Asaf', provider: 'twitter', uid: 'UID', oauth_token: 'TOKEN'

        # If user exists we not update BaseUser from old session because existing user should already have one
        base_user.reload
        expect(base_user.user_id).to be_nil

        # ensuring existing BaseUser was kept
        expect(existing_base_user.user_id).to eq user.id
      end
    end

    after(:all) do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:twitter] = nil
    end
  end
end