# frozen_string_literal: true

require 'rails_helper'

describe InvolvedAuthority do
  describe 'validations' do
    subject { record.valid? }

    let(:role) { :author }
    let(:record) { build(:involved_authority, role: role, item: item) }

    context 'when item is not specified' do
      let(:item) { nil }

      it { is_expected.to be false }
    end

    context 'when expression is specified' do
      let(:item) { create(:expression) }

      context 'when work-level role is specified' do
        it { is_expected.to be false }
      end

      context 'when expression-level role is specified' do
        let(:role) { :editor }

        it { is_expected.to be_truthy }
      end
    end

    context 'when work is specified' do
      let(:item) { create(:work) }

      context 'when work-level role is specified' do
        it { is_expected.to be_truthy }
      end

      context 'when expression-level role is specified' do
        let(:role) { :translator }

        it { is_expected.to be false }
      end
    end
  end
end
