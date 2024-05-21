require 'rails_helper'

describe AdminController do
  describe '#authors_without_works' do
    subject(:call) { get :authors_without_works }

    include_context 'when editor logged in'

    before do
      create_list(:manifestation, 5)
      create_list(:person, 3)
      allow(Rails.cache).to receive(:write)
    end

    it 'is successful' do
      expect(call).to be_successful
      expect(Rails.cache).to have_received(:write).with('report_authors_without_works', 3)
    end
  end

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
    let(:copyrighted_person) { create(:person, intellectual_property: :copyrighted) }
    let(:by_permission_person) { create(:person, intellectual_property: :permission_for_selected) }
    let(:public_domain_person) { create(:person, intellectual_property: :public_domain) }

    let!(:public_domain) do
      create(
        :manifestation,
        orig_lang: 'he',
        intellectual_property: :public_domain,
        author: public_domain_person
      )
    end

    let!(:public_domain_translated) do
      create(
        :manifestation,
        orig_lang: 'ru',
        intellectual_property: :public_domain,
        translator: public_domain_person,
        author: public_domain_person
      )
    end

    let!(:by_permission_translated) do
      create(
        :manifestation,
        orig_lang: 'ru',
        intellectual_property: :by_permission,
        translator: by_permission_person,
        author: public_domain_person
      )
    end

    let!(:wrong_public_domain) do
      create(
        :manifestation,
        orig_lang: 'he',
        intellectual_property: :public_domain,
        author: copyrighted_person
      )
    end

    let!(:wrong_public_domain_translated) do
      create(
        :manifestation,
        orig_lang: 'de',
        intellectual_property: :public_domain,
        author: public_domain_person,
        translator: by_permission_person
      )
    end

    let!(:wrong_by_permission) do
      create(
        :manifestation,
        orig_lang: 'he',
        intellectual_property: :by_permission,
        author: public_domain_person
      )
    end

    let!(:wrong_copyrighted_translated) do
      create(
        :manifestation,
        orig_lang: 'de',
        intellectual_property: :copyrighted,
        author: public_domain_person,
        translator: public_domain_person
      )
    end

    let(:wrong_manifestation_ids) do
      [
        wrong_public_domain.id,
        wrong_public_domain_translated.id,
        wrong_by_permission.id,
        wrong_copyrighted_translated.id
      ]
    end

    it 'renders successfully' do
      expect(request).to be_successful
      expect(assigns(:incong).map(&:id)).to match_array wrong_manifestation_ids
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
    subject(:call) { get :suspicious_titles }

    include_context 'Admin user logged in'

    let!(:suspicious_titles) do
      [
        create(:manifestation, title: 'קבוצה '),
        create(:manifestation, title: 'Trailing dot.'),
        create(:manifestation, title: 'ab')
      ]
    end

    before do
      create_list(:manifestation, 5)
      allow(Rails.cache).to receive(:write)
    end

    it 'completes successfully' do
      expect(call).to be_successful
      expect(Rails.cache).to have_received(:write).with('report_suspicious_titles', suspicious_titles.length)
      expect(assigns(:suspicious)).to match_array suspicious_titles
    end
  end

  describe '#suspicious_translations' do
    subject(:request) { get :suspicious_translations }

    include_context 'Admin user logged in'

    let(:person) { create(:person) }

    before do
      create(:manifestation, language: 'he', orig_lang: 'de', author: person, translator: person)
      create(:manifestation, language: 'he', orig_lang: 'de', author: person, translator: person)
    end

    it { is_expected.to be_successful }
  end

  describe '#missing_copyright' do
    subject(:request) { get :missing_copyright }

    include_context 'Admin user logged in'

    let!(:unknown_person) { create(:person, intellectual_property: :unknown) }

    let!(:by_permission_manifestation) { create(:manifestation, intellectual_property: :by_permission) }
    let!(:public_domain_manifestation) { create(:manifestation, intellectual_property: :public_domain) }
    let!(:unknown_manifestations) { create_list(:manifestation, 3, intellectual_property: :unknown) }

    before do
      allow(Rails.cache).to receive(:write)
    end

    it 'shows records where copyright is nil' do
      expect(request).to be_successful
      expect(assigns(:mans)).to eq unknown_manifestations
      expect(assigns(:authors)).to eq [unknown_person]
      expect(Rails.cache).to have_received(:write).with('report_missing_copyright', unknown_manifestations.length)
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

  describe 'Featured author functionality' do
    include_context 'Admin user logged in'

    describe '#featured_author_list' do
      subject { get :featured_author_list }

      before do
        create_list(:featured_author, 3)
      end

      it { is_expected.to be_successful }
    end

    describe '#featured_author_new' do
      subject { get :featured_author_new }

      it { is_expected.to be_successful }
    end

    describe '#featured_author_create' do
      subject(:call) { post :featured_author_create, params: { featured_author: create_params } }

      let(:person) { create(:person) }

      context 'when params are valid' do
        let(:create_params) do
          {
            title: 'Title',
            body: 'Body',
            person_id: person.id
          }
        end

        it 'creates record' do
          expect { call }.to change(FeaturedAuthor, :count).by(1)
          fa = FeaturedAuthor.order(id: :desc).first
          expect(call).to redirect_to featured_author_show_path(fa)
        end
      end
    end

    describe 'Member actions' do
      let!(:featured_author) { create(:featured_author) }

      describe '#featured_author_show' do
        subject { get :featured_author_show, params: { id: featured_author.id } }

        it { is_expected.to be_successful }
      end

      describe '#featured_author_edit' do
        subject { get :featured_author_edit, params: { id: featured_author.id } }

        it { is_expected.to be_successful }
      end

      describe '#featured_author_update' do
        subject(:call) do
          post :featured_author_update, params: { id: featured_author.id, featured_author: update_params }
        end

        let(:update_params) do
          {
            title: 'New Title',
            body: 'New Body'
          }
        end

        it 'updates record' do
          expect(call).to redirect_to featured_author_show_path(featured_author)
          featured_author.reload
          expect(featured_author).to have_attributes(update_params)
        end
      end

      describe '#featured_author_destroy' do
        subject(:call) { delete :featured_author_destroy, params: { id: featured_author.id } }

        it 'deletes record' do
          expect { call }.to change(FeaturedAuthor, :count).by(-1)
          expect(call).to redirect_to admin_featured_author_list_path
        end
      end
    end
  end
end
