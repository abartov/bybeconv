# frozen_string_literal: true

require 'rails_helper'

describe InvolvedAuthoritiesController do
  describe '#destroy' do
    subject(:call) { delete :destroy, params: { id: involved_authority.id }, format: :js }

    include_context 'when editor logged in'

    let(:manifestation) { create(:manifestation) }
    let!(:involved_authority) { create(:involved_authority, work: work, expression: expression, role: :editor) }

    context 'when Expression authority' do
      let(:work) { nil }
      let(:expression) { manifestation.expression }

      it 'destroys record' do
        expect { call }.to change(InvolvedAuthority, :count).by(-1)
        expect(call).to be_successful
      end
    end

    context 'when Work authority' do
      let(:work) { manifestation.expression.work }
      let(:expression) { nil }

      it 'destroys record' do
        expect { call }.to change(InvolvedAuthority, :count).by(-1)
        expect(call).to be_successful
      end
    end
  end
end
