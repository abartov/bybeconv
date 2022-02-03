require 'rails_helper'

describe PreferencesController do
  describe 'update' do
    let!(:base_user) { create(:base_user, session_id: session.id.private_id) }
    subject { patch :update, params: { id: pref, value: value} }
    let(:pref) { :fontsize }
    let(:value) { 10 }

    context 'when preference does not exists' do
      it 'creates new preference record' do
        expect { subject }.to change { base_user.preferences.count }.by(1)
        expect(subject).to be_successful
        base_user.reload
        expect(base_user.preferences.fontsize).to eq "10"
      end
    end

    context 'when preference already exists' do
      before do
        base_user.preferences.fontsize = 5
        base_user.preferences.save!
      end

      it 'updates preference record' do
        expect { subject }.to_not change { base_user.preferences.count }
        expect(subject).to be_successful
        base_user.reload
        expect(base_user.preferences.fontsize).to eq "10"
      end
    end
  end
end