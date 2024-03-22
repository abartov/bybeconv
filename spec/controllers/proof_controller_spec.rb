require 'rails_helper'

describe ProofController do
  let(:user) { create(:user, editor: true) }

  before do
    create(:list_item, item: user, listkey: :handle_proofs)
    session[:user_id] = user.id
  end

  describe '#show' do
    subject { get :show, params: { id: proof.id } }

    context 'when proof is for manifestation' do
      let!(:manifestation) { create(:manifestation) }
      let!(:proof) { create(:proof, manifestation: manifestation) }

      it { is_expected.to be_successful }
    end
  end

  describe '#create' do
    let(:email) { 'john.doe@test.com' }
    let(:ziburit) { 'ביאליק' }
    let(:errors) { assigns(:errors) }

    let(:manifestation) { create(:manifestation) }

    let(:params) do
      {
        from: email,
        highlight: 'highlight text',
        what: 'what text',
        manifestation: manifestation.id,
        ziburit: ziburit
      }
    end

    subject(:call) { post :create, params: params, format: :js }

    context 'when everything is OK' do
      it { is_expected.to be_successful }
      it 'creates new Proof record with given params' do
        expect { call }.to change { Proof.count }.by(1)
        expect(Proof.order(id: :desc).first).to have_attributes(
          status: 'new',
          from: email,
          what: 'what text',
          highlight: 'highlight text',
          manifestation: manifestation
        )
      end
    end

    context 'when email is missing' do
      let(:email) { ' ' }

      it 'returns error' do
        expect(call).to be_unprocessable
        expect(JSON.parse(response.body)).to eq([I18n.t('proof.create.email_missing')])
      end
      it { expect { call }.not_to change { Proof.count } }
    end

    context 'when control question failed' do
      let(:ziburit) { 'WRONG' }

      it 'returns error' do
        expect(call).to be_unprocessable
        expect(JSON.parse(response.body)).to eq([I18n.t('proof.create.ziburit_failed')])
      end

      it { expect { call }.not_to change { Proof.count } }
    end
  end
end
