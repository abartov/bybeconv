# frozen_string_literal: true

require 'rails_helper'

describe Person do
  describe 'validations' do
    it 'considers empty Person invalid' do
      p = described_class.new
      expect(p).not_to be_valid
    end

    it 'considers Person with all mandatory fields filled as valid' do
      p = described_class.new(name: Faker::Artist.name, intellectual_property: :public_domain)
      expect(p).to be_valid
    end

    describe '.wikidata_uri' do
      subject(:result) { person.valid? }

      let(:person) { build(:person, wikidata_uri: value) }

      context 'when value is blank' do
        let(:value) { '  ' }

        it 'succeed but sets value to nil' do
          expect(result).to be_truthy
          expect(person.wikidata_uri).to be_nil
        end
      end

      context 'when uri has wrong format' do
        let(:value) { 'http://wikidata.org/wiki/q1234' }

        it { is_expected.to be false }
      end

      context 'when uri is correct but id is not numeric' do
        let(:value) { 'https://wikidata.org/wiki/Q1234A' }

        it { is_expected.to be false }
      end

      context 'when value has correct format' do
        let(:value) { '  HTTPS://wikidata.org/WIKI/Q1234  ' }

        it 'succeed, removes leading/trailing whitespaces and converts to downcase' do
          expect(result).to be true
          expect(person.wikidata_uri).to eq 'https://wikidata.org/wiki/Q1234'
        end
      end
    end
  end

  describe 'instance methods' do
    let(:person) { create(:person) }

    describe '.all_genres' do
      subject { person.all_genres }

      before do
        create(:manifestation, author: person, genre: 'poetry')
        create(:manifestation, author: person, genre: 'poetry')
        create(:manifestation, illustrator: person, genre: 'fables') # illustrated works should not be included
        create(:manifestation, translator: person, orig_lang: 'ru', genre: 'article')
        create(:manifestation, translator: person, orig_lang: 'ru', genre: 'memoir')
        create(:manifestation, editor: person, genre: 'prose') # edited works should not be included
      end

      it { is_expected.to eq %w(article memoir poetry) }
    end

    describe '.most_read' do
      subject { person.most_read(limit).pluck(:id) }

      let!(:manifestation_1) { create(:manifestation, author: person, impressions_count: 10, genre: :fables) }
      let!(:manifestation_2) { create(:manifestation, author: person, impressions_count: 20, genre: :memoir) }
      let!(:manifestation_3) { create(:manifestation, author: person, impressions_count: 30, genre: :article) }

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
      subject(:latest_stuff) { person.latest_stuff }

      let!(:original_work) { create(:manifestation, author: person) }
      let!(:translated_work) { create(:manifestation, orig_lang: 'ru', translator: person) }
      let!(:edited_work) { create(:manifestation, orig_lang: 'ru', editor: person) }

      it 'returns latest original and translated works' do
        expect(latest_stuff).to contain_exactly(original_work, translated_work)
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
        create(:manifestation, title: "original translated #{title} work", language: 'he', orig_lang: 'ru',
                               author: person, translator: person)
      end

      before do
        # those records has different title
        create_list(:manifestation, 2, language: 'he', orig_lang: 'ru', translator: person)
        create_list(:manifestation, 2, author: person)
      end

      it { is_expected.to contain_exactly(original_work, translated_work, original_and_translated_work) }
    end

    describe '.manifestations' do
      let!(:as_author) { create(:manifestation, author: person) }
      let!(:as_translator) { create(:manifestation, translator: person, orig_lang: 'en') }
      let!(:as_author_and_illustrator) { create(:manifestation, author: person, illustrator: person) }
      let!(:as_author_unpublished) { create(:manifestation, author: person, status: :unpublished) }
      let!(:as_illustrator_on_expression_level) do
        create(:manifestation).tap do |manifestation|
          manifestation.expression.involved_authorities.create!(role: :illustrator, person: person)
        end
      end

      before do
        create_list(:manifestation, 5)
      end

      context 'when single role is passed' do
        it 'returns all manifestations where person has given role, including unpublished' do
          expect(person.manifestations(:author)).to contain_exactly(
            as_author,
            as_author_unpublished,
            as_author_and_illustrator
          )
          expect(person.manifestations(:translator)).to eq [as_translator]
          expect(person.manifestations(:illustrator)).to contain_exactly(
            as_author_and_illustrator,
            as_illustrator_on_expression_level
          )
          expect(person.manifestations(:editor)).to be_empty
        end
      end

      context 'when several roles are passed' do
        it 'returns all manifestations where person has given role, including unpublished' do
          expect(person.manifestations(:author, :editor)).to contain_exactly(
            as_author,
            as_author_unpublished,
            as_author_and_illustrator
          )

          expect(person.manifestations(:author, :translator)).to contain_exactly(
            as_author,
            as_author_unpublished,
            as_author_and_illustrator,
            as_translator
          )

          expect(person.manifestations(:translator, :illustrator)).to contain_exactly(
            as_translator,
            as_author_and_illustrator,
            as_illustrator_on_expression_level
          )

          expect(person.manifestations(:editor, :other)).to be_empty
        end
      end

      context 'when no roles are passed' do
        it 'returns all manifestations where person has any role, including unpublished' do
          expect(person.manifestations).to contain_exactly(
            as_author,
            as_author_unpublished,
            as_author_and_illustrator,
            as_translator,
            as_illustrator_on_expression_level
          )
        end
      end
    end

    describe '.published_manifestations' do
      let!(:as_author) { create(:manifestation, author: person) }
      let!(:as_translator) { create(:manifestation, translator: person, orig_lang: 'en') }
      let!(:as_author_and_illustrator) { create(:manifestation, author: person, illustrator: person) }
      let!(:as_author_unpublished) { create(:manifestation, author: person, status: :unpublished) }

      before do
        create_list(:manifestation, 5)
      end

      it 'works correctly and ignores unpublished works' do
        expect(person.published_manifestations).to contain_exactly(as_author, as_translator, as_author_and_illustrator)
        expect(person.published_manifestations(:author)).to contain_exactly(as_author, as_author_and_illustrator)
        expect(person.published_manifestations(:translator, :illustrator)).to contain_exactly(
          as_translator, as_author_and_illustrator
        )
        expect(person.published_manifestations(:editor)).to be_empty
      end
    end

    describe '.original_works_by_genre' do
      subject(:result) { person.original_works_by_genre }

      let!(:fables) { create_list(:manifestation, 5, genre: :fables, author: person) }
      let!(:poetry) { create_list(:manifestation, 2, genre: :poetry, author: person) }

      it 'works correctly' do
        expect(result).to eq({
                               'article' => [],
                               'drama' => [],
                               'fables' => fables,
                               'letters' => [],
                               'lexicon' => [],
                               'memoir' => [],
                               'poetry' => poetry,
                               'prose' => [],
                               'reference' => []
                             })
      end
    end

    describe '.translations_by_genre' do
      subject(:result) { person.translations_by_genre }

      let!(:memoirs) { create_list(:manifestation, 5, genre: :memoir, orig_lang: :ru, translator: person) }
      let!(:poetry) { create_list(:manifestation, 2, genre: :poetry, orig_lang: :en, translator: person) }
      let!(:articles) { create_list(:manifestation, 3, genre: :article, orig_lang: :de, translator: person) }

      it 'works correctly' do
        expect(result).to eq({
                               'article' => articles,
                               'drama' => [],
                               'fables' => [],
                               'letters' => [],
                               'lexicon' => [],
                               'memoir' => memoirs,
                               'poetry' => poetry,
                               'prose' => [],
                               'reference' => []
                             })
      end
    end
  end
end
