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

    after(:all) do
      clean_tables
    end
  end

  describe 'read' do
    subject { get :read, params: { id: manifestation.id } }

    it { is_expected.to be_successful }
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
end