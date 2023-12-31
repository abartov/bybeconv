require 'rails_helper'

describe Work do
  describe 'works_about' do
    let(:subject) { work.works_about.order(:id).to_a }
    let!(:work) { create(:work) }
    let!(:about_1)  {
      create(:work) do |w|
        create(:aboutness, work: w, aboutable: work)
      end
    }
    let!(:about_2)  {
      create(:work) do |w|
        create(:aboutness, work: w, aboutable: work)
      end
    }
    it { is_expected.to eq [about_1, about_2] }
  end

  it 'validates and normalizes dates before saving' do
    w = Work.new
    expect(w).to_not be_valid
    w.title = 'foo'
    expect(w).to_not be_valid
    w.date = '3 ביוני 1960'
    expect(w).to_not be_valid
    w.genre = 'nonexistent_genre'
    expect(w).to_not be_valid
    w.primary = true
    expect(w).to_not be_valid
    w.genre = Work::GENRES.sample
    expect(w).to be_valid
    w.save
    w = Work.last
    expect(w.normalized_creation_date).to eq '1960-06-03'
  end

  it 'finds authors' do
    w = create(:work)
    expect(w.authors).to eq [w.involved_authorities.first.authority]
  end

  it 'finds illustrators' do
    ill = create(:person)
    w = create(:work, illustrator: ill)
    expect(w.illustrators).to eq [ill]
  end
end