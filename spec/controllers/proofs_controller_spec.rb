require 'rails_helper'

describe ProofsController do
  include_context 'when editor logged in', :handle_proofs

  describe '#index' do
    let(:manifestation) { create(:manifestation, title: 'Search Term') }

    let!(:new_proof) { create(:proof, status: :new, item: manifestation) }
    let!(:escalated_proof) { create(:proof, status: :escalated) }
    let!(:fixed_proof) { create(:proof, status: :fixed, item: manifestation) }
    let!(:wontfix_proof) { create(:proof, status: :wontfix) }
    let!(:spam_proof) { create(:proof, status: :spam, item: manifestation) }

    subject!(:call) { get :index, params: filter }

    context 'when no params are given' do
      let(:filter) { {} }

      it 'shows all proofs except spam' do
        expect(call).to be_successful
        expect(assigns[:proofs]).to contain_exactly(new_proof, escalated_proof, fixed_proof, wontfix_proof)
      end
    end

    context 'when filter by status is set' do
      let(:filter) { { status: :new } }

      it 'shows all proofs of selected status' do
        expect(call).to be_successful
        expect(assigns[:proofs]).to contain_exactly(new_proof)
      end
    end

    context 'when search term is given' do
      let(:filter) { { search: 'SEARCH TERM' } }

      it 'shows all matching proofs except spam' do
        expect(call).to be_successful
        expect(assigns[:proofs]).to contain_exactly(new_proof, fixed_proof)
      end
    end
  end

  describe '#purge' do
    before do
      create_list(:proof, 2, status: :new)
      create_list(:proof, 3, status: :spam)
      create_list(:proof, 2, status: :escalated)
      create_list(:proof, 2, status: :wontfix)
      create_list(:proof, 2, status: :fixed)
    end

    subject(:call) { post :purge }

    it 'removes all spam records' do
      expect { call }.to change { Proof.count }.by(-3)
      expect(call).to redirect_to proofs_path
      expect(Proof.where(status: :spam).count).to eq 0
    end
  end

  describe '#show' do
    subject { get :show, params: { id: proof.id } }

    context 'when proof is for manifestation' do
      let!(:manifestation) { create(:manifestation) }
      let!(:proof) { create(:proof, item: manifestation) }

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
        item_type: 'Manifestation',
        item_id: manifestation.id,
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
          item: manifestation
        )
      end
    end

    context 'when email is missing' do
      let(:email) { ' ' }

      it 'returns error' do
        expect(call).to be_unprocessable
        expect(JSON.parse(response.body)).to eq([I18n.t('proofs.create.email_missing')])
      end
      it { expect { call }.not_to change { Proof.count } }
    end

    context 'when control question failed' do
      let(:ziburit) { 'WRONG' }

      it 'returns error' do
        expect(call).to be_unprocessable
        expect(JSON.parse(response.body)).to eq([I18n.t('proofs.create.ziburit_failed')])
      end

      it { expect { call }.not_to change { Proof.count } }
    end
  end

  describe '#resolve' do
    let!(:manifestation) { create(:manifestation) }
    let!(:proof) { create(:proof, status: :new, item: manifestation, from: 'test@test.com') }

    subject(:call) { post :resolve, params: { id: proof.id, fixed: fixed }.merge(additional_params) }

    before do
      allow(Notifications).to receive(:proof_wontfix)
    end

    context 'when fixed' do
      before do
        allow(Notifications).to receive(:proof_fixed).and_call_original
      end

      let(:additional_params) { { email: email, fixed_explanation: 'FIXED' } }
      let(:email) { 'no' }
      let(:fixed) { 'yes' }

      it 'marks proof as fixed and redirects to admin index page' do
        expect(call).to redirect_to admin_index_path
        expect(Notifications).not_to have_received(:proof_fixed)
        proof.reload
        expect(proof.status).to eq 'fixed'
      end

      context 'when current user is an admin' do
        before do
          current_user.update!(admin: true)
        end

        it 'marks proof as fixed and redirects to new proofs page' do
          expect(call).to redirect_to proofs_path(status: :new)
          expect(Notifications).not_to have_received(:proof_fixed)
          proof.reload
          expect(proof.status).to eq 'fixed'
        end
      end

      context 'when email is requested' do
        let(:email) { 'yes' }

        it 'marks proof as fixed and sends email' do
          expect(call).to redirect_to admin_index_path
          expect(Notifications).to have_received(:proof_fixed)
          proof.reload
          expect(proof.status).to eq 'fixed'
        end
      end
    end

    context 'when not fixed' do
      let(:fixed) { 'no' }

      before do
        allow(Notifications).to receive(:proof_wontfix).and_call_original
      end

      context 'when escalated' do
        let(:additional_params) { { escalate: 'yes' } }

        it 'marks proof as escalated and redirects to admin index page' do
          expect(call).to redirect_to admin_index_path
          expect(Notifications).not_to have_received(:proof_wontfix)
          proof.reload
          expect(proof.status).to eq 'escalated'
        end
      end

      context 'when wontfix' do
        let(:additional_params) { { escalate: 'no', wontfix_explanation: 'EXPLANATION' } }

        it 'marks proof as wontfix, sends an email and redirects to admin index page' do
          expect(call).to redirect_to admin_index_path
          expect(Notifications).to have_received(:proof_wontfix)
          proof.reload
          expect(proof.status).to eq 'wontfix'
        end

        context 'when email is not requested' do
          let(:additional_params) { { escalate: 'no', email: 'no', wontfix_explanation: 'EXPLANATION' } }

          it 'marks proof as wontfix without sending email' do
            expect(call).to redirect_to admin_index_path
            expect(Notifications).not_to have_received(:proof_wontfix)
            proof.reload
            expect(proof.status).to eq 'wontfix'
          end
        end
      end
    end
  end
end
