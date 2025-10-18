# frozen_string_literal: true

require 'rails_helper'

describe IngestibleCollectionAuthoritiesController do
  include_context 'when editor logged in', :edit_catalog

  let(:ingestible) { create(:ingestible, locked_by_user: nil, locked_at: nil) }
  let(:authority) { create(:authority) }

  describe '#create' do
    subject(:call) do
      post :create, params: { ingestible_id: ingestible.id, authority_id: authority.id,
                              authority_name: authority.name, role: 'editor' }, xhr: true, format: :js
    end

    it 'adds authority to collection_authorities' do
      call
      ingestible.reload
      coll_auths = JSON.parse(ingestible.collection_authorities)
      expect(coll_auths.length).to eq(1)
      expect(coll_auths.first['authority_id']).to eq(authority.id)
      expect(coll_auths.first['role']).to eq('editor')
    end

    context 'when default_authorities is blank' do
      it 'mirrors to default_authorities' do
        ingestible.update!(default_authorities: '')
        call
        ingestible.reload
        expect(ingestible.default_authorities).to eq(ingestible.collection_authorities)
      end
    end

    context 'when default_authorities was manually changed' do
      let(:manual_authority) { create(:authority) }

      it 'does not mirror to default_authorities' do
        manual_default = [{ seqno: 1, authority_id: manual_authority.id, authority_name: manual_authority.name,
                            role: 'translator' }].to_json
        ingestible.update!(default_authorities: manual_default, collection_authorities: '')
        call
        ingestible.reload
        expect(ingestible.default_authorities).to eq(manual_default)
        expect(ingestible.collection_authorities).not_to eq(manual_default)
      end
    end
  end

  describe '#destroy' do
    let(:coll_auth) do
      [{ seqno: 1, authority_id: authority.id, authority_name: authority.name, role: 'editor' }]
    end

    before do
      ingestible.update!(collection_authorities: coll_auth.to_json)
    end

    subject(:call) do
      delete :destroy, params: { ingestible_id: ingestible.id, id: 1 }, xhr: true, format: :js
    end

    it 'removes authority from collection_authorities' do
      call
      ingestible.reload
      coll_auths = JSON.parse(ingestible.collection_authorities)
      expect(coll_auths).to be_empty
    end

    context 'when mirroring is active' do
      before do
        ingestible.update!(default_authorities: coll_auth.to_json)
      end

      it 'also removes from default_authorities' do
        call
        ingestible.reload
        expect(ingestible.default_authorities).to eq(ingestible.collection_authorities)
        expect(JSON.parse(ingestible.default_authorities)).to be_empty
      end
    end
  end

  describe '#replace' do
    let(:coll_auth) do
      [{ seqno: 1, new_person: 'Unknown Person', role: 'editor' }]
    end

    before do
      ingestible.update!(collection_authorities: coll_auth.to_json)
    end

    subject(:call) do
      post :replace, params: { ingestible_id: ingestible.id, seqno: 1, authority_id: authority.id,
                               authority_name: authority.name, role: 'editor' }, xhr: true, format: :js, member: true
    end

    it 'replaces new_person with authority' do
      call
      ingestible.reload
      coll_auths = JSON.parse(ingestible.collection_authorities)
      expect(coll_auths.first['authority_id']).to eq(authority.id)
      expect(coll_auths.first['new_person']).to be_nil
    end
  end
end
