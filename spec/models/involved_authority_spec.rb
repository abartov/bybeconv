# frozen_string_literal: true

require 'rails_helper'

describe InvolvedAuthority do
  describe 'validations' do
    subject { record.valid? }

    let(:role) { :author }
    let(:work) { nil }
    let(:expression) { nil }
    let(:record) { build(:involved_authority, role: role, work: work, expression: expression) }

    context 'when nor work nor expression are specified' do
      it { is_expected.to be false }
    end

    context 'when expression is specified' do
      let(:expression) { create(:expression) }

      context 'when work-level role is specified' do
        it { is_expected.to be false }
      end

      context 'when expression-level role is specified' do
        let(:role) { :editor }

        it { is_expected.to be_truthy }
      end
    end

    context 'when work is specified' do
      let(:work) { create(:work) }

      context 'when work-level role is specified' do
        it { is_expected.to be_truthy }
      end

      context 'when expression-level role is specified' do
        let(:role) { :translator }

        it { is_expected.to be false }
      end
    end

    context 'when both work and expression are specified' do
      let(:work) { create(:work) }
      let(:expression) { create(:expression) }

      it { is_expected.to be false }
    end
  end
end
