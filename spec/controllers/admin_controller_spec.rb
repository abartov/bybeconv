require 'rails_helper'

describe AdminController do
  describe '#missing_genre' do
    subject { get :missing_genres }

    # include_context 'Unauthorized access to admin page' # no longer restricted to admins

    context 'when admin user is authorized' do
      include_context 'Admin user logged in'

      it { is_expected.to be_successful }
    end
  end

  describe '#suspicious_headings' do
    subject { get :suspicious_headings }

    include_context 'Admin user logged in'

    before do
      create(:manifestation, cached_heading_lines: '1|2|3|4', markdown: "Some\nmultiline\ntext\nfor\n\test")
    end

    it { is_expected.to be_successful }
  end

  describe '#suspicious_titles' do
    subject { get :suspicious_titles }

    include_context 'Admin user logged in'

    before do
      create(:manifestation, cached_heading_lines: '1|2|3|4', markdown: "Some\nmultiline\ntext\nfor\n\test")
    end

    it { is_expected.to be_successful }
  end

  describe '#tocs_missing_links' do
    subject { get :tocs_missing_links }

    let(:toc) { create(:toc) }
    let(:author) { create(:person, toc: toc) }

    before do
      create_list(:manifestation, 3, author: author)
      create_list(:manifestation, 3, orig_lang: 'ru', translator: author)
    end

    include_context 'Admin user logged in'

    it { is_expected.to be_successful }
  end

  describe '#incongruous_copyright' do
    include_context 'Admin user logged in'
    subject(:request) { get :incongruous_copyright }

    let(:copyrighted_person) { create(:person, public_domain: false) }

    let!(:public_domain_manifestation) { create(:manifestation, copyrighted: false) }
    let!(:copyrighted_manifestation) { create(:manifestation, author: copyrighted_person, copyrighted: true) }
    let!(:wrong_public_domain_manifestation_1) { create(:manifestation, author: copyrighted_person, copyrighted: false) }
    let!(:wrong_public_domain_manifestation_2) { create(:manifestation, orig_lang: 'ru', translator: copyrighted_person, copyrighted: false) }
    let!(:wrong_copyrighted_manifestation_1) { create(:manifestation, copyrighted: true) }
    let!(:wrong_copyrighted_manifestation_2) { create(:manifestation, orig_lang: 'ru', copyrighted: true) }

    let(:wrong_manifestation_ids) {
      [
        wrong_public_domain_manifestation_1.id,
        wrong_public_domain_manifestation_2.id,
        wrong_copyrighted_manifestation_1.id,
        wrong_copyrighted_manifestation_2.id
      ]
    }

    it 'renders successfully' do
      expect(request).to be_successful
      expect(assigns(:incong).map(&:first).map(&:id)).to match_array wrong_manifestation_ids
    end
  end

  describe '#missing_languages' do
    include_context 'Admin user logged in'
    subject(:request) { get :missing_languages }

    before do
      create_list(:manifestation, 60, language: 'ru', orig_lang: 'he')
    end

    it { is_expected.to be_successful }
  end

  describe '#suspicious_titles' do
    include_context 'Admin user logged in'
    subject { get :suspicious_titles }

    before do
      create(:manifestation, title: 'קבוצה ')
      create(:manifestation, title: 'Trailing dot.')
    end

    it { is_expected.to be_successful }
  end

  describe '#suspicious_translations' do
    include_context 'Admin user logged in'
    subject(:request) { get :suspicious_translations }

    let(:person) { create(:person) }

    before do
      create(:manifestation, language: 'he', orig_lang: 'de', author: person, translator: person)
      create(:manifestation, language: 'he', orig_lang: 'de', author: person, translator: person)
    end

    it { is_expected.to be_successful }
  end

  describe '#missing_copyright' do
    include_context 'Admin user logged in'
    subject(:request) { get :missing_copyright }

    let!(:copyrighted_manifestation) { create(:manifestation, copyrighted: true) }
    let!(:public_domain_manifestation) { create(:manifestation, copyrighted: false) }
    let!(:missing_copyright_manifestation) { create(:manifestation, copyrighted: nil) }

    it 'shows records where copyright is nil' do
      expect(request).to be_successful
      expect(assigns(:mans)).to eq [missing_copyright_manifestation]
    end
  end

  describe '#translated_from_multiple_languages' do
    subject(:request) { get :translated_from_multiple_languages }

    include_context 'Admin user logged in'

    let(:author) { create(:person) }
    let!(:german_works) { create_list(:manifestation, 3, orig_lang: :de, author: author) }
    let!(:russian_works) { create_list(:manifestation, 5, orig_lang: :ru, author: author) }
    let!(:hebrew_works) { create_list(:manifestation, 2, orig_lang: :he, author: author) }

    before do
      # some additional manifestations to be ignroed
      create_list(:manifestation, 5)
    end

    it 'shows authors having original works in different languages' do
      expect(request).to be_successful
      authors = assigns(:authors)
      expect(authors.length).to eq 1
      expect(authors[0][0]).to eq author
      expect(authors[0][1]).to match_array %w(he ru de)
      expect(authors[0][2]).to eq ({ 'he' => hebrew_works, 'ru' => russian_works, 'de' => german_works })
    end
  end
end
