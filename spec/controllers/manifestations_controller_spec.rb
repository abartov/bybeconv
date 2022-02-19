require 'rails_helper'

describe ManifestationController do
  let!(:manifestation) { create(:manifestation) }

  describe 'browse' do
    before(:all) do
      clean_tables
      Chewy.strategy(:atomic) do
        create_list(:manifestation, 10)
      end
    end

    subject { get :browse }

    context 'when user is not logged in' do
      it { is_expected.to be_successful }
    end

    context 'when user is logged in' do
      let!(:user) { create(:user) }
      before do
        session[:user_id] = user.id
      end

      it { is_expected.to be_successful }
    end

    describe 'sorting' do
      subject { get :browse, params: { sort_by: "#{sort_by}_#{sort_dir}" } }

      # Simply ensure all sort combinations works
      %w(alphabetical pupularity creation_date publication_date upload_date).each do | sort_by |
        %w(asc desc).each do |dir|
          context "when #{dir} sorting by #{sort_by} is requested" do
            let(:sort_by) { sort_by }
            let(:sort_dir) { dir }
            it { is_expected.to be_successful }
          end
        end
      end
    end

    describe 'paging' do
      subject { get :browse, params: { page: page } }

      context 'when page number 0 is requested' do
        let(:page) { 0 }
        it 'returns first page' do
          expect(subject).to be_successful
        end
      end

      context 'when page number is not specified' do
        let(:page) { nil }
        it 'returns first page' do
          expect(subject).to be_successful
        end
      end

      context 'when requested page number is greater than total number of pages' do
        let(:page) { 2 }
        it { is_expected.to be_not_found }
      end
    end

    after(:all) do
      clean_tables
    end
  end

  describe 'read' do
    subject { get :read, params: { id: manifestation.id } }

    context 'when user is not logged in' do
      it { is_expected.to be_successful }
    end

    context 'when user is logged in' do
      let!(:user) { create(:user) }
      before do
        session[:user_id] = user.id
      end

      it { is_expected.to be_successful }
    end
  end

  describe 'print' do
    subject { get :print, params: { id: manifestation.id } }

    it { is_expected.to be_successful }
  end

  describe 'edit_metadata' do
    subject { get :edit_metadata, params: { id: manifestation.id } }

    context 'when user is not signed it' do
      it { is_expected.to redirect_to('/') }
    end

    context 'when user is signed in' do
      let(:user) { create(:user, editor: editor_flag) }

      before do
        session[:user_id] = user.id
      end

      context 'when user is not an editor' do
        let(:editor_flag) { false }
        it { is_expected.to redirect_to('/') }
      end

      context 'when user is an editor' do
        let(:editor_flag) { true }
        it { is_expected.to redirect_to('/') }

        context 'when user has edit_catalog bit' do
          let!(:edit_catalog_bit) { create(:list_item, item: user, listkey: :edit_catalog) }
          it { is_expected.to be_successful }
        end
      end
    end
  end

  describe 'set_bookmark' do
    let!(:base_user) { create :base_user, session_id: session.id.private_id }
    let(:manifestation) { create(:manifestation) }
    subject { post :set_bookmark, params: { id: manifestation.id, bookmark_path: 'NEW_P' }, format: :js }

    context 'when user already have bookmark in this text' do
      let!(:bookmark) { create(:bookmark, base_user: base_user, manifestation: manifestation) }
      it 'updates record with new bookmark value' do
        expect { subject }.to_not change { Bookmark.count }
        expect(response).to be_successful
        bookmark.reload
        expect(bookmark).to have_attributes(bookmark_p: 'NEW_P', manifestation: manifestation, base_user: base_user)
      end
    end

    context 'when user have no bookmarks in this text' do
      it 'updates record with new bookmark value' do
        expect { subject }.to change { Bookmark.count }.by(1)
        expect(response).to be_successful
        bookmark = base_user.bookmarks.first
        expect(bookmark).to have_attributes(bookmark_p: 'NEW_P', manifestation: manifestation)
      end
    end
  end

  describe 'remove_bookmark' do
    let(:base_user) { create :base_user, session_id: session.id.private_id }
    let(:manifestation) { create(:manifestation) }
    let(:other_manifestation) { create(:manifestation) }
    let(:other_base_user) { create(:base_user, session_id: '12345') }
    let!(:bookmark) { create(:bookmark, base_user: base_user, manifestation: manifestation) }
    let!(:other_bookmark) { create(:bookmark, base_user: base_user, manifestation: other_manifestation) }
    let!(:other_base_user_bookmark) { create(:bookmark, base_user: other_base_user, manifestation: manifestation) }
    subject { post :remove_bookmark, params: { id: manifestation.id }, format: :js }

    it 'deletes bookmark of current user from given text' do
      expect { subject }.to change { Bookmark.count }.by(-1)
      expect(response).to be_successful
      expect { bookmark.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end