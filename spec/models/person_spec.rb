require 'rails_helper'

describe Person do
  describe 'validations' do
    it 'considers empty Person invalid' do
      p = described_class.new
      expect(p).to_not be_valid
    end

    it 'considers Person with all mandatory fields filled as valid' do
      p = described_class.new(name: Faker::Artist.name, intellectual_property: :public_domain)
      expect(p).to be_valid
    end
  end

  describe 'instance methods' do
    let(:person) { create(:person) }

    describe '.all_genres' do
      subject { person.all_genres }

      before do
        create(:manifestation, author: person, genre: 'poetry')
        create(:manifestation, author: person, genre: 'poetry')
        create(:manifestation, illustrator: person, genre: 'fables')
        create(:manifestation, translator: person, orig_lang: 'ru', genre: 'article')
        create(:manifestation, translator: person, orig_lang: 'ru', genre: 'memoir')
        create(:manifestation, editor: person, genre: 'prose') # edited works should not be included
      end

      it { is_expected.to eq %w(article fables memoir poetry) }
    end

    describe '.most_read' do
      let!(:manifestation_1) { create(:manifestation, author: person, impressions_count: 10, genre: :fables) }
      let!(:manifestation_2) { create(:manifestation, author: person, impressions_count: 20, genre: :memoir) }
      let!(:manifestation_3) { create(:manifestation, author: person, impressions_count: 30, genre: :article) }

      subject { person.most_read(limit).map{ |rec| rec[:id] } }

      context 'when limit is less than total number of works' do
        let(:limit) { 2 }
        it { is_expected.to eq [manifestation_3.id, manifestation_2.id] }
      end

      context 'when limit is equal to total number of works' do
        let(:limit) { 3 }
        it { is_expected.to eq [manifestation_3.id, manifestation_2.id, manifestation_1.id] }
      end

      context 'when limit is bigger than total number of works' do
        let(:limit) { 4 }
        it { is_expected.to eq [manifestation_3.id, manifestation_2.id, manifestation_1.id] }
      end
    end

    describe '.has_any_hebrew_works?' do
      subject { person.has_any_hebrew_works? }

      context 'when person has no works' do
        it { is_expected.to be false }
      end

      context 'when person has original and translated works but not in hebrew' do
        before do
          create(:manifestation, language: 'he', orig_lang: 'de', author: person)
          create(:manifestation, language: 'en', orig_lang: 'he', translator: person)
        end

        it { is_expected.to be false }
      end

      context 'when person has original work in hebrew' do
        before do
          create(:manifestation, language: 'de', orig_lang: 'he', author: person)
        end

        it { is_expected.to be_truthy }
      end

      context 'when person has translated work in hebrew' do
        before do
          create(:manifestation, language: 'he', orig_lang: 'ru', translator: person)
        end

        it { is_expected.to be_truthy }
      end
    end

    describe '.has_any_non_hebrew_works?' do
      subject { person.has_any_non_hebrew_works? }

      context 'when person has no works' do
        it { is_expected.to be false }
      end

      context 'when person has non-hebrew work' do
        before do
          create(:manifestation, orig_lang: 'ru', author: person)
        end

        it { is_expected.to be_truthy }
      end

      context 'when person has non-hebrew work' do
        before do
          create(:manifestation, orig_lang: 'he', author: person)
        end

        it { is_expected.to be false }
      end
    end

    describe '.latest_stuff' do
      let!(:original_work) { create(:manifestation, author: person) }
      let!(:translated_work) { create(:manifestation, orig_lang: 'ru', translator: person) }
      let!(:edited_work) { create(:manifestation, orig_lang: 'ru', editor: person) }

      subject(:latest_stuff) { person.latest_stuff }

      it 'returns latest original and translated works' do
        expect(latest_stuff).to match_array [original_work, translated_work]
      end

      context 'when more than 20 records present' do
        before do
          create_list(:manifestation, 25, author: person)
        end

        it 'returns first 20 records only' do
          expect(latest_stuff.length).to eq 20
        end
      end
    end

    describe '.cached_works_count' do
      subject { person.cached_works_count }

      before do
        create(:manifestation, author: person) # should be counted
        create(:manifestation, editor: person) # should be counted
        create(:manifestation, orig_lang: 'de', author: person, translator: person) # should be counted only once
        create(:manifestation, author: person, status: :unpublished) # should not be counted
        create(:manifestation, editor: person, status: :unpublished) # should not be counted
        create(:manifestation)                                       # should not be counted
      end

      it { is_expected.to eq 3 }
    end

    describe '.all_works_by_title' do
      subject { person.all_works_by_title(title) }

      let(:title) { 'search term' }
      let!(:translated_work) do
        create(:manifestation, title: "translated #{title} work", language: 'he', orig_lang: 'ru', translator: person)
      end
      let!(:original_work) do
        create(:manifestation, title: "original #{title} work", author: person)
      end

      # this item should not be duplicated
      let!(:original_and_translated_work) do
        create(:manifestation, title: "original translated #{title} work", language: 'he', orig_lang: 'ru', author: person, translator: person)
      end

      before do
        # those records has different title
        create_list(:manifestation, 2, language: 'he', orig_lang: 'ru', translator: person)
        create_list(:manifestation, 2, author: person)
      end

      it { is_expected.to match_array [original_work, translated_work, original_and_translated_work] }
    end
  end
end
