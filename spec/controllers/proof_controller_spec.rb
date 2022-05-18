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
end
