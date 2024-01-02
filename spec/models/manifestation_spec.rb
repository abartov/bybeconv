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

  describe '.manual_delete' do
    let!(:manifestation) { create(:manifestation, orig_lang: 'de') }

    subject(:manual_delete) { manifestation.manual_delete }

    it 'removes record with all dependent subrecords' do
      expect { manual_delete }.to change { Manifestation.count }.by(-1).
        and change { Expression.count }.by(-1).
        and change { Work.count }.by(-1).
        and change { InvolvedAuthority.count }.by(-2). # author and translator removed
        and change { Person.count }.by(0)     # people records are kept
    end
  end

  describe '.authors_string' do
    subject { manifestation.authors_string }
    context 'when authors present' do
      let(:author_1) { create(:person, name: 'Alpha') }
      let(:author_2) { create(:person, name: 'Beta') }
      let(:manifestation) { create(:manifestation, author: author_1) }
      before do
        create(:involved_authority, item: manifestation.expression.work, role: :author, authority: author_2)
      end
      it { is_expected.to eq 'Alpha, Beta' }
    end

    context 'when no authors present' do
      let(:manifestation) { create(:manifestation) }

      before do
        manifestation.expression.work.involved_authorities.delete_all
      end

      it { is_expected.to eq I18n.t(:nil) }
    end
  end

  describe '.translators_string' do
    subject { manifestation.translators_string }
    context 'when translators present' do
      let(:translator_1) { create(:person, name: 'Alpha') }
      let(:translator_2) { create(:person, name: 'Beta') }
      let(:manifestation) { create(:manifestation, orig_lang: 'de', translator: translator_1) }
      before do
        create(:involved_authority, item: manifestation.expression, role: :translator, authority: translator_2)
      end
      it { is_expected.to eq 'Alpha, Beta' }
    end

    context 'when no authors present' do
      let(:manifestation) { create(:manifestation) }

      before do
        manifestation.expression.involved_authorities.delete_all
      end

      it { is_expected.to eq I18n.t(:nil) }
    end
  end

  describe '.author_string' do
    subject { manifestation.author_string }

    let(:author_1) { create(:person, name: 'Alpha') }
    let(:author_2) { create(:person, name: 'Beta') }

    before do
      create(:involved_authority, item: manifestation.expression.work, role: :author, authority: author_2)
    end

    context 'when work is not a translation' do
      let(:manifestation) { create(:manifestation, orig_lang: 'he', author: author_1) }

      context 'when authors are present' do
        it { is_expected.to eq 'Alpha, Beta' }
      end

      context 'when no authors present' do
        before do
          manifestation.expression.work.involved_authorities.delete_all
        end

        it { is_expected.to eq I18n.t(:nil) }
      end
    end

    context 'when work is a translation' do
      let(:translator_1) { create(:person, name: 'Gamma') }
      let(:translator_2) { create(:person, name: 'Delta') }

      let(:manifestation) { create(:manifestation, orig_lang: 'de', author: author_1, translator: translator_1) }

      before do
        create(:involved_authority, item: manifestation.expression, role: :translator, authority: translator_2)
      end

      context 'when both authors and transaltors are present' do
        it { is_expected.to eq 'Alpha, Beta / Gamma, Delta' }
      end

      context 'when no authors present' do
        before do
          manifestation.expression.work.involved_authorities.delete_all
        end

        it { is_expected.to eq I18n.t(:nil) }
      end

      context 'when no translators present' do
        before do
          manifestation.expression.involved_authorities.delete_all
        end

        it { is_expected.to eq 'Alpha, Beta / ' + I18n.t(:unknown) }
      end
    end
  end

  describe '.title_and_authors_html' do
    subject(:string) { manifestation.title_and_authors_html }

    context 'when work is not a translation' do
      let(:manifestation) { create(:manifestation, orig_lang: :he) }

      it 'does not include info about translation' do
        expect(string.include?(I18n.t(:translated_from))).to be false
      end
    end

    context 'when work is a translation' do
      let(:manifestation) { create(:manifestation, orig_lang: :de) }

      it 'includes info about translation' do
        expect(string.include?(I18n.t(:translated_from))).to be_truthy
      end
    end
  end
end
