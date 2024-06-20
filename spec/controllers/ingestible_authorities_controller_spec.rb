# frozen_string_literal: true

require 'rails_helper'

describe IngestibleAuthoritiesController do
  include_context 'when editor logged in', :edit_catalog

  let(:ingestible) { create(:ingestible, default_authorities: authorities&.to_json) }

  let(:authorities) do
    [
      { seqno: 1, new_person: 'Jack London', role: :author },
      { seqno: 2, authority_id: 10, authority_name: 'Jane Doe', role: :editor }
    ]
  end

  let(:updated_authorities) do
    ingestible.reload
    JSON.parse(ingestible.default_authorities)
  end

  describe '#create' do
    subject(:call) { post :create, params: { ingestible_id: ingestible.id }.merge(params), format: :js }

    context 'when new person should be created' do
      let(:params) { { role: 'translator', new_person: 'John Doe' } }

      it 'adds new record to default_authorities' do
        expect(call).to be_successful
        expect(updated_authorities.size).to eq(3)
        expect(updated_authorities[2]).to eq({ 'seqno' => 3, 'new_person' => 'John Doe', 'role' => 'translator' })
      end

      context 'when default_authorities are nil' do
        let(:authorities) { nil }

        it 'adds new record with seqno = 1 to default_authorities' do
          expect(call).to be_successful
          expect(updated_authorities.size).to eq(1)
          expect(updated_authorities[0]).to eq({ 'seqno' => 1, 'new_person' => 'John Doe', 'role' => 'translator' })
        end
      end
    end

    context 'when existing authority should be added' do
      let(:params) { { role: 'translator', authority_id: 11, authority_name: 'John Doe' } }

      it 'adds new record to default_authorities' do
        expect(call).to be_successful
        expect(updated_authorities.size).to eq(3)
        expect(updated_authorities[2]).to eq(
          {
            'seqno' => 3,
            'authority_id' => 11,
            'authority_name' => 'John Doe',
            'role' => 'translator'
          }
        )
      end
    end

    context 'when nor new_person nor authority_id is provided' do
      let(:params) { { authority_name: 'John Doe' } }

      it { is_expected.to have_http_status(:bad_request) }
    end
  end

  describe '#destroy' do
    subject(:call) { post :destroy, params: { ingestible_id: ingestible.id, id: 1 }, format: :js }

    it 'removes record with given seqno from default_authorities' do
      expect(call).to be_successful
      expect(updated_authorities.size).to eq(1)
      expect(updated_authorities.detect { |a| a['seqno'] == 1 }).to be_nil
    end
  end
end
