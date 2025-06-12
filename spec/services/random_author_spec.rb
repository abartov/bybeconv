# frozen_string_literal: true

require 'rails_helper'

describe RandomAuthor do
  describe '#call' do
    before do
      create_list(:manifestation, 5, status: :published, genre: :drama)
      create_list(:manifestation, 5, status: :published, genre: :poetry)
      create_list(:manifestation, 5, status: :published, genre: :lexicon)
    end

    context 'when genre is not provided' do
      subject { described_class.call }

      it { is_expected.to be_an Authority }
    end

    context 'when genre is provided' do
      subject { described_class.call('fables') }

      let!(:fable) { create(:manifestation, genre: :fables) }

      it { is_expected.to eq fable.authors.first }
    end
  end
end
