# frozen_string_literal: true

require 'rails_helper'

describe Ingestible do
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
