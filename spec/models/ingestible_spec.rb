# frozen_string_literal: true

require 'rails_helper'

describe Ingestible do
  describe 'collection_authorities and default_authorities' do
    let(:ingestible) { create(:ingestible) }
    let(:authority1) { create(:authority) }
    let(:authority2) { create(:authority) }

    describe '#should_mirror_authorities?' do
      context 'when default_authorities is blank' do
        it 'returns true' do
          ingestible.default_authorities = ''
          ingestible.collection_authorities = [{ seqno: 1, authority_id: authority1.id,
                                                  authority_name: authority1.name, role: 'author' }].to_json
          expect(ingestible.should_mirror_authorities?).to be true
        end
      end

      context 'when default_authorities matches old collection_authorities' do
        it 'returns true' do
          old_coll = [{ seqno: 1, authority_id: authority1.id, authority_name: authority1.name,
                        role: 'author' }].to_json
          ingestible.collection_authorities = old_coll
          ingestible.default_authorities = old_coll
          ingestible.save!
          # Now change collection_authorities
          new_coll = [{ seqno: 1, authority_id: authority2.id, authority_name: authority2.name,
                        role: 'author' }].to_json
          ingestible.collection_authorities = new_coll
          expect(ingestible.should_mirror_authorities?).to be true
        end
      end

      context 'when default_authorities has been manually changed' do
        it 'returns false' do
          ingestible.collection_authorities = [{ seqno: 1, authority_id: authority1.id,
                                                 authority_name: authority1.name, role: 'author' }].to_json
          ingestible.default_authorities = [{ seqno: 1, authority_id: authority2.id,
                                              authority_name: authority2.name, role: 'translator' }].to_json
          ingestible.save!
          # Now change collection_authorities - should not mirror
          new_coll = [{ seqno: 1, authority_id: authority1.id, authority_name: authority1.name,
                        role: 'editor' }].to_json
          ingestible.collection_authorities = new_coll
          expect(ingestible.should_mirror_authorities?).to be false
        end
      end
    end

    describe '#mirror_collection_to_default_authorities' do
      it 'copies collection_authorities to default_authorities' do
        coll_auth = [{ seqno: 1, authority_id: authority1.id, authority_name: authority1.name,
                       role: 'author' }].to_json
        ingestible.collection_authorities = coll_auth
        ingestible.mirror_collection_to_default_authorities
        expect(ingestible.default_authorities).to eq(coll_auth)
      end
    end

    describe '#update_authorities_and_metadata_from_volume' do
      let(:collection) { create(:collection) }
      let!(:involved_authority) do
        collection.involved_authorities.create!(authority: authority1, role: :author)
      end

      it 'populates collection_authorities from volume' do
        ingestible.update!(prospective_volume_id: collection.id.to_s)
        ingestible.update_authorities_and_metadata_from_volume
        expect(ingestible.collection_authorities).to be_present
        coll_auths = JSON.parse(ingestible.collection_authorities)
        expect(coll_auths.length).to eq(1)
        expect(coll_auths.first['authority_id']).to eq(authority1.id)
        expect(coll_auths.first['role']).to eq('author')
      end

      it 'mirrors to default_authorities when appropriate' do
        ingestible.default_authorities = ''
        ingestible.update!(prospective_volume_id: collection.id.to_s)
        ingestible.update_authorities_and_metadata_from_volume
        expect(ingestible.default_authorities).to eq(ingestible.collection_authorities)
      end

      it 'does not mirror when default_authorities was manually changed' do
        manual_default = [{ seqno: 1, authority_id: authority2.id, authority_name: authority2.name,
                            role: 'translator' }].to_json
        ingestible.default_authorities = manual_default
        ingestible.collection_authorities = ''
        ingestible.save!
        ingestible.update!(prospective_volume_id: collection.id.to_s)
        ingestible.update_authorities_and_metadata_from_volume
        expect(ingestible.default_authorities).to eq(manual_default)
        expect(ingestible.collection_authorities).not_to eq(manual_default)
      end
    end
  end

  describe '.locked?' do
    subject { ingestible.locked? }

    let(:ingestible) { create(:ingestible, locked_by_user: user, locked_at: locked_at) }

    context 'when record is not locked' do
      let(:locked_at) { nil }
      let(:user) { nil }

      it { is_expected.to be false }
    end

    context 'when record is locked less than 15 minutes ago' do
      let(:locked_at) { 890.seconds.ago }
      let(:user) { create(:user) }

      it { is_expected.to be true }
    end

    context 'when record is locked more than 15 minutes ago' do
      let(:locked_at) { 901.seconds.ago }
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '.obtain_lock' do
    subject(:result) { ingestible.obtain_lock(user) }

    let(:user) { create(:user) }
    let(:ingestible) { create(:ingestible, locked_by_user: other_user, locked_at: locked_at) }

    shared_examples 'lock obtained' do
      it 'locks record and returns true' do
        expect(result).to be_truthy
        ingestible.reload
        expect(ingestible.locked_by_user).to eq user
        expect(ingestible.locked_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context 'when record is not locked' do
      let(:locked_at) { nil }
      let(:other_user) { nil }

      it_behaves_like 'lock obtained'
    end

    context 'when record is locked by same user' do
      let(:locked_at) { 5.minutes.ago }
      let(:other_user) { user }

      it_behaves_like 'lock obtained'
    end

    context 'when record is locked by same user less than 10 seconds ago' do
      let(:locked_at) { 5.seconds.ago }
      let(:other_user) { user }

      it 'returns true but does not updates lock timestamp' do
        expect(result).to be_truthy
        ingestible.reload
        expect(ingestible.locked_by_user).to eq user
        expect(ingestible.locked_at).to be_within(1.second).of(locked_at)
      end
    end

    context 'when record is locked by different user, but lock is expired' do
      let(:locked_at) { 20.minutes.ago }
      let(:other_user) { create(:user) }

      it_behaves_like 'lock obtained'
    end

    context 'when record is locked by different user and lock is not expired' do
      let(:locked_at) { 10.minutes.ago }
      let(:other_user) { create(:user) }

      it 'returns false and does not changes lock information' do
        expect(result).to be false
        ingestible.reload
        expect(ingestible.locked_by_user).to eq other_user
        expect(ingestible.locked_at).to be_within(1.second).of(locked_at)
      end
    end
  end
end
