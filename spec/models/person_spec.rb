require 'rails_helper'

describe Person do
  it 'considers empty Person invalid' do
    p = Person.new
    expect(p).to_not be_valid
  end

  it 'considers Person with only name as valid' do
    p = Person.new(name: Faker::Artist.name)
    expect(p).to be_valid
  end

  describe '.all_genres' do
    let(:person) { create(:person) }

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
    let(:person) { create(:person) }

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
end