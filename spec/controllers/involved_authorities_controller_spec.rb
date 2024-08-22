# frozen_string_literal: true

require 'rails_helper'

describe InvolvedAuthoritiesController do
  describe '#destroy' do
    subject(:call) { delete :destroy, params: { id: involved_authority.id }, format: :js }

    include_context 'when editor logged in'

    let(:manifestation) { create(:manifestation) }
    let!(:involved_authority) { create(:involved_authority, item: item, role: :editor) }

    context 'when Expression authority' do
      let(:item) { manifestation.expression }

      it 'destroys record' do
        expect { call }.to change(InvolvedAuthority, :count).by(-1)
        expect(call).to be_successful
      end
    end

    context 'when Work authority' do
      let(:item) { manifestation.expression.work }

      it 'destroys record' do
        expect { call }.to change(InvolvedAuthority, :count).by(-1)
        expect(call).to be_successful
      end
    end

    context 'when Collection authority' do
      let(:item) { create(:collection, manifestations: [manifestation]) }

      it 'destroys record' do
        expect { call }.to change(InvolvedAuthority, :count).by(-1)
        expect(call).to be_successful
      end
    end
  end
end
