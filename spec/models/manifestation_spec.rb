require 'rails_helper'

describe Manifestation do
  describe '.safe_filename' do
    let(:manifestation) { create(:manifestation) }
    let(:subject) { manifestation.safe_filename }

    it { is_expected.to eq manifestation.id.to_s }
  end

  describe '.genre(genre)' do
    before do
      create_list(:manifestation, 3, genre: :article)
      create_list(:manifestation, 2, genre: :article, status: :unpublished)
      create_list(:manifestation, 4, genre: :prose)
    end

    it 'takes in account unpublished manifestations as well' do
      expect(described_class.genre(:article).count).to eq 5
    end
  end

  describe '.cached_work_counts_by_genre' do
    subject { described_class.cached_work_counts_by_genre }

    before do
      create_list(:manifestation, 3, genre: :article)
      create_list(:manifestation, 4, genre: :prose)
      create_list(:manifestation, 5, genre: :fables)
    end

    let(:expected_result) do
      {
        'article' => 3,
        'drama' => 0,
        'fables' => 5,
        'letters' => 0,
        'lexicon' => 0,
        'memoir' => 0,
        'poetry' => 0,
        'prose' => 4,
        'reference' => 0
      }
    end

    it { is_expected.to eq expected_result }

    context 'when unpublished works exists' do
      before do
        create_list(:manifestation, 2, genre: :article, status: :unpublished)
        create_list(:manifestation, 2, genre: :lexicon, status: :unpublished)
        create_list(:manifestation, 2, genre: :prose, status: :unpublished)
      end

      it 'does not takes them in account' do
        expect(subject).to eq expected_result
      end
    end
  end
end