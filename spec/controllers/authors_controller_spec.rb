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
    let!(:author) { create(:authority) }

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

    describe '#list' do
      subject { get :list }

      before do
        create_list(:authority, 5)     # authors without works
        create_list(:manifestation, 5) # this will create authors with works
        create_list(:publication, 2)   # will create authors with publications
      end

      it { is_expected.to be_successful }
    end

    describe '#new' do
      subject { get :new }

      it { is_expected.to be_successful }
    end

    describe '#create' do
      subject(:call) { post :create, params: { authority: authority_params } }

      let(:intellectual_property) { 'permission_for_selected' }
      let(:status) { 'published' }

      let(:person_attributes) { { birthdate: '1850' } }
      let(:authority_attributes) do
        {
          name: 'New name',
          intellectual_property: intellectual_property,
          status: status
        }
      end

      let(:authority_params) do
        authority_attributes.merge(person_attributes: person_attributes)
      end

      let(:created_authority) { Authority.order(id: :desc).first }

      context 'when save successful' do
        it 'creates record' do
          expect { call }.to change(Authority, :count).by(1).and change(Person, :count).by(1)
          expect(created_authority).to have_attributes(authority_attributes)
          expect(created_authority.person).to have_attributes(person_attributes)

          expect(call).to redirect_to authors_show_path(id: created_authority.id)
          expect(flash.notice).to eq I18n.t(:created_successfully)
        end

        context 'when status is not set' do
          let(:status) { nil }

          context 'when intellectual_property is public_domain' do
            let(:intellectual_property) { 'public_domain' }

            it 'sets status to awaiting_first' do
              expect { call }.to change(Authority, :count).by(1)
              expect(created_authority.status).to eq 'awaiting_first'
            end
          end

          context 'when intellectual_property is not public_domain' do
            let(:intellectual_property) { 'permission_for_selected' }

            it 'sets status to unpublished' do
              expect { call }.to change(Authority, :count).by(1)
              expect(created_authority.status).to eq 'unpublished'
            end
          end
        end
      end

      context 'when save fails' do
        let(:status) { :unpublished }
        let(:intellectual_property) { nil }

        it 're-renders new form' do
          expect { call }.not_to change(Authority, :count)
          expect(call).to render_template(:new)
          expect(call).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'member actions' do
      let(:period) { 'revival' }
      let(:intellectual_property) { :public_domain }
      let(:author) { create(:authority, intellectual_property: intellectual_property, period: period) }

      describe '#show' do
        subject(:call) { get :show, params: { id: author.id } }

        before do
          create_list(:manifestation, 3, author: author)
          create(:manifestation, author: author, status: :unpublished)
          create_list(:manifestation, 6, translator: author, orig_lang: 'de')
          create_list(:manifestation, 2, translator: author, orig_lang: 'de', status: :unpublished)
        end

        it 'renders successfully' do
          expect(call).to be_successful
          expect(assigns(:published_works)).to eq 3
          expect(assigns(:published_xlats)).to eq 6
          expect(assigns(:total_orig_works)).to eq 4
          expect(assigns(:total_xlats)).to eq 8
        end

        context 'when non-public domain' do
          # there is a special logic in view for such case
          let(:intellectual_property) { :permission_for_selected }

          it { is_expected.to be_successful }
        end

        context 'when bibliography exists' do
          let!(:publications) { create_list(:publication, 3, authority: author) }

          it { is_expected.to be_successful }
        end
      end

      describe '#publish' do
        subject { get :publish, params: { id: author.id } }

        before do
          create_list(:manifestation, 3, author: author, status: :unpublished)
        end

        it { is_expected.to be_successful }
      end

      describe '#edit' do
        subject { get :edit, params: { id: author.id } }

        it { is_expected.to be_successful }
      end

      describe '#edit_toc' do
        subject(:call) { get :edit_toc, params: { id: author.id } }

        context 'when TOC does not exists yet' do
          it 'redirects to home page' do
            expect(call).to redirect_to '/'
            expect(flash['error']).to eq I18n.t('no_toc_yet')
          end
        end

        context 'when TOC exists' do
          let(:toc) { create(:toc) }

          before do
            author.toc = toc
            author.save!
          end

          it { is_expected.to be_successful }
        end
      end

      describe '#update' do
        subject(:request) do
          put :update, params: {
            id: author.id,
            authority: {
              name: new_name,
              intellectual_property: new_intellectual_property,
              wikidata_uri: new_wikidata_uri,
              person_attributes: {
                id: author.person.id,
                period: new_period
              }
            }
          }
        end

        let(:new_name) { 'New Name' }
        let(:new_intellectual_property) { 'unknown' }
        let(:new_wikidata_uri) { 'https://wikidata.org/wiki/Q1234' }

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
            expect(author).to have_attributes(
              name: new_name,
              intellectual_property: new_intellectual_property,
              wikidata_uri: new_wikidata_uri
            )
            expect(author.person).to have_attributes(period: new_period)
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
            expect(author).to have_attributes(
              name: new_name,
              intellectual_property: new_intellectual_property,
              wikidata_uri: new_wikidata_uri
            )
            expect(author.person).to have_attributes(period: new_period)
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

        context 'when validation error occurs' do
          let(:new_wikidata_uri) { 'https://wrongsite.com/Q123' }
          let(:new_period) { period }

          it 'fails to save and re-renders edit form' do
            expect(request).to have_http_status(:unprocessable_entity)
            expect(response).to render_template :edit
          end
        end
      end
    end
  end
end
