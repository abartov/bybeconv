# frozen_string_literal: true

require 'rails_helper'

describe ExtractYear do
  subject(:call) { described_class.call(datestr) }

  context 'when datestr is blank' do
    let(:datestr) { "  \n\t" }

    it { is_expected.to eq('') }

    context 'when default value provided' do
      subject(:call) { described_class.call(datestr, 'UNKNOWN') }

      it { is_expected.to eq('UNKNOWN') }
    end
  end

  context 'when date is provided in YYYY-MM-DD format' do
    let(:datestr) { '2018-06-17' }

    it { is_expected.to eq('2018') }

    context 'when there are excessive whitespaces' do
      let(:datestr) { "  2015\t-  02 - 18  \n\t" }

      it { is_expected.to eq('2015') }
    end
  end

  context 'when year only is provided' do
    let(:datestr) { ' 718  ' }

    it { is_expected.to eq('718') }
  end

  context 'when datestr does not contains digits' do
    let(:datestr) { 'Sixth century' }

    it { is_expected.to eq('Sixth century') }
  end
end
