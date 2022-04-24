require 'rails_helper'

describe AnthologiesController do
  describe '#show' do
    let(:user) { create(:user) }

    let(:access) { :priv }
    let(:anthology) { create(:anthology, access: access) }

    subject { get :show, params: { id: anthology.id } }

    context 'when user is not signed in' do
      it { is_expected.to redirect_to '/' }
    end

    context 'when user signed in' do
      context "when user tries to see other user's anthology" do
        context 'when anthology is public' do
          let(:access) { :pub }
          it { is_expected.to be_successful }
        end

        context 'when anthology is unlisted' do
          let(:access) { :unlisted }
          it { is_expected.to be_successful }
        end

        context 'when anthology is private' do
          it { is_expected.to redirect_to '/' }
        end
      end
    end
  end
end
