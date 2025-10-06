# frozen_string_literal: true

require 'rails_helper'

describe LifePeriod do
  before do
    stub_const(
      'Model',
      Class.new do
        include LifePeriod

        attr_accessor :birthdate, :deathdate

        def initialize(birthdate, deathdate)
          @birthdate = birthdate
          @deathdate = deathdate
        end
      end
    )
  end

  let(:model) { Model.new(birthdate, deathdate) }
  let(:birthdate) { '1923-01-22' }
  let(:deathdate) { '1976-05-12' }

  describe '.death_year' do
    subject { model.death_year }

    it { is_expected.to eq('1976') }

    context 'when deathdate is nil' do
      let(:deathdate) { nil }

      it { is_expected.to eq('') }
    end
  end

  describe '.birth_year' do
    subject { model.birth_year }

    it { is_expected.to eq('1923') }

    context 'when birthdate is blank' do
      let(:birthdate) { '   ' }

      it { is_expected.to eq('') }
    end
  end

  describe '.life_years' do
    subject { model.life_years }

    it { is_expected.to eq('1923&rlm;-1976') }

    context 'when deathdate is nil' do
      let(:deathdate) { nil }

      it { is_expected.to eq('1923&rlm;-') }
    end

    context 'when birthdate is nil' do
      let(:birthdate) { nil }

      it { is_expected.to eq('&rlm;-1976') }
    end

    context 'when both dates are nil' do
      let(:birthdate) { nil }
      let(:deathdate) { nil }

      it { is_expected.to eq('&rlm;-') }
    end
  end
end
