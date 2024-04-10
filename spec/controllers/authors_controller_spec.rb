require 'rails_helper'

describe AuthorsController do
  describe '#browse' do
    subject(:call) { get :browse }

    before do
      clean_tables
      Chewy.strategy(:atomic) do
        create_list(:manifestation, 20)
      end
    end

    it { is_expected.to be_successful }
  end

  describe '#get_random_author' do
    before do
      create_list(:manifestation, 5)
      # we need to have bunch of authors with TOCs
      authors = Person.joins(:creations).merge(Creation.author).to_a
      authors.each do |author|
        toc = create(:toc)
        author.toc = toc
        author.save!
      end
    end

    context 'when genre is not provided' do
      subject { get :get_random_author, params: { } }
      it { is_expected.to be_successful }
    end

    context 'when genre provided' do
      let(:genre) { Work.first.genre }

      subject { get :get_random_author, params: { genre: genre } }
      it { is_expected.to be_successful }
    end
  end

  describe 'member actions' do
    let!(:author) { create(:person) }

    describe '#toc' do
      let(:toc) { create(:toc) }

      before do
        create_list(:manifestation, 5, author: author, created_at: 3.days.ago)
        author.toc = toc
        author.save!
      end

      subject(:request) { get :toc, params: { id: author.id } }

      it 'renders successfully' do
        expect(request).to be_successful
      end

      context 'when fresh work exists' do
        before do
          create(:manifestation, author: author, created_at: 6.hours.ago)
        end

        it 'renders successfully' do
          expect(request).to be_successful
        end
      end
    end

    describe '#whatsnew_popup' do
      let!(:manifestation) { create(:manifestation, created_at: created_at, author: author) }

      subject { get :whatsnew_popup, params: { id: author.id } }

      context 'when there is a new work in last month' do
        let(:created_at) { 20.days.ago }
        it { is_expected.to be_successful }
      end

      context 'when there is no new works in last month' do
        let(:created_at) { 35.days.ago }
        it { is_expected.to be_successful }
      end
    end

    describe '#latest_popup' do
      subject { get :latest_popup, params: { id: author.id } }

      context 'when author has works' do
        before do
          create_list(:manifestation, 25, author: author)
        end
        it { is_expected.to be_successful }
      end

      context 'when there are no works' do
        it { is_expected.to be_successful }
      end
    end

    describe '#print' do
      subject { get :print, params: { id: author.id } }

      before do
        create(:manifestation, author: author)
        create(:manifestation, orig_lang: 'de', translator: author)
      end

      it { is_expected.to be_successful }
    end
  end

  describe 'Editor actions' do
    let(:user) { create(:user, editor: true, admin: true) }

    before do
      create(:list_item, item: user, listkey: :edit_people)
      session[:user_id] = user.id
    end

    describe 'member actions' do
      let(:period) { 'revival' }
      let(:author) { create(:person, public_domain: true, period: period) }

      describe '#show' do
        before do
          create_list(:manifestation, 3, author: author)
          create(:manifestation, author: author, status: :unpublished)
          create_list(:manifestation, 6, translator: author, orig_lang: 'de')
          create_list(:manifestation, 2, translator: author, orig_lang: 'de', status: :unpublished)
        end

        subject! { get :show, params: { id: author.id } }

        it 'renders successfully' do
          expect(response).to be_successful
          expect(assigns(:published_works)).to eq 3
          expect(assigns(:published_xlats)).to eq 6
          expect(assigns(:total_orig_works)).to eq 4
          expect(assigns(:total_xlats)).to eq 8
        end
      end

      describe '#publish' do
        subject { get :publish, params: { id: author.id } }

        before do
          create_list(:manifestation, 3, author: author, status: :unpublished)
        end

        it { is_expected.to be_successful }
      end

      describe '#update' do
        let(:new_name) { 'New Name' }
        subject(:request) do
          put :update, params: {
            id: author.id,
            person: {
              name: new_name,
              period: new_period
            }
          }
        end

        let(:works_period) { 'modern' } # intentionally use value different from author period
        let!(:original_work) { create(:manifestation, orig_lang: 'he', author: author, period: works_period) }
        let!(:original_foreign_work) { create(:manifestation, orig_lang: 'ru', language: 'he', author: author, period: works_period) }
        let!(:translated_work) { create(:manifestation, orig_lang: 'ru', translator: author, period: works_period) }
        let!(:translated_to_foreign_work) { create(:manifestation, orig_lang: 'he', language: 'ru', translator: author, period: works_period) }

        context 'when period attribute was changed' do
          let(:new_period) { 'ancient' }

          it 'updates author and sets period in his hebrew works and translations to hebrew' do
            expect(request).to redirect_to authors_show_path(id: author.id)
            author.reload
            expect(author).to have_attributes(name: new_name, period: new_period)
            original_work.reload
            expect(original_work.expression.period).to eq new_period
            translated_work.reload
            expect(translated_work.expression.period).to eq new_period

            # period of original work in foreign language is not changed
            original_foreign_work.reload
            expect(original_foreign_work.expression.period).to eq works_period

            # period of translation to foreign language is not changed
            translated_to_foreign_work.reload
            expect(translated_to_foreign_work.expression.period).to eq works_period
          end
        end

        context 'when period is not changed' do
          let(:new_period) { period }

          it 'updates author but not his works' do
            expect(request).to redirect_to authors_show_path(id: author.id)
            author.reload
            expect(author).to have_attributes(name: new_name, period: new_period)
            original_work.reload
            expect(original_work.expression.period).to eq works_period
            translated_work.reload
            expect(translated_work.expression.period).to eq works_period
            original_foreign_work.reload
            expect(original_foreign_work.expression.period).to eq works_period
            translated_to_foreign_work.reload
            expect(translated_to_foreign_work.expression.period).to eq works_period
          end
        end
      end
    end
  end
end
