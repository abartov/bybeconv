# frozen_string_literal: true

require 'rails_helper'

describe CollectionsController do
  let(:collection) do
    create(
      :collection,
      manifestations: create_list(:manifestation, 3),
      included_collections: create_list(:collection, 2)
    )
  end

  describe '#show' do
    subject { get :show, params: { id: collection.id } }

    it { is_expected.to be_successful }
  end

  describe 'editor actions' do
    include_context 'when editor logged in'

    describe '#create' do
      subject(:call) { post :create, params: { collection: collection_params } }

      let(:toc) { create(:toc) }
      let(:publication) { create(:publication) }

      let(:collection_params) do
        {
          title: title,
          sort_title: title,
          subtitle: Faker::Book.title,
          issn: 'new_issn',
          collection_type: 'volume',
          inception: 'new_inception',
          inception_year: 2024,
          publication_id: publication.id,
          toc_id: toc.id,
          toc_strategy: 'default'
        }
      end

      context 'when params are valid' do
        let(:title) { Faker::Book.title }

        it 'creates record' do
          expect { call }.to change(Collection, :count).by(1)
          collection = Collection.order(id: :desc).first
          expect(collection).to have_attributes(collection_params)
        end
      end

      context 'when params are invalid' do
        let(:title) { '' }

        it 'rejects the submission as unprocessable' do
          expect { call }.to not_change(Collection, :count)
          expect(call).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe '#update' do
      subject(:call) { patch :update, params: { id: collection.id, collection: collection_params } }

      let(:toc) { create(:toc) }
      let(:publication) { create(:publication) }

      let(:collection_params) do
        {
          title: title,
          sort_title: title,
          subtitle: Faker::Book.title,
          issn: 'new_issn',
          collection_type: 'volume',
          inception: 'new_inception',
          inception_year: 2024,
          publication_id: publication.id,
          toc_id: toc.id,
          toc_strategy: 'default'
        }
      end

      context 'when params are valid' do
        let(:title) { Faker::Book.title }

        it 'updates record' do
          expect(call).to redirect_to collection
          expect(flash.notice).to eq I18n.t(:updated_successfully)
          collection.reload
          expect(collection).to have_attributes(collection_params)
        end
      end

      context 'when params are invalid' do
        let(:title) { '' }

        it 'rejects the submission as unprocessable' do
          expect(call).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe '#destroy' do
      subject(:call) { delete :destroy, params: { id: collection.id } }

      before do
        collection
      end

      it 'removes record' do
        expect { call }.to change(Collection, :count).by(-1)
        expect(call).to redirect_to collections_path
        expect(flash.notice).to eq I18n.t(:deleted_successfully)
      end
    end

    describe '#drag_item' do
      subject(:call) { post :drag_item, params: { id: collection.id, old_index: old_index, new_index: new_index } }

      let(:titles) { Array.new(5) { |index| (index + 1).to_s } }
      let!(:collection) { create(:collection, title_placeholders: titles) }
      let(:collection_item) { collection.collection_items[old_index] }

      shared_examples 'drags successfully' do
        it 'moves item to new position' do
          expect(call).to be_successful
          expect(collection_item.reload.seqno).to eq(new_index + 1)
          collection.reload
          expect(collection.collection_items.pluck(:alt_title)).to eq(expected_order)
          expect(collection.collection_items.pluck(:seqno)).to eq([1, 2, 3, 4, 5])
        end
      end

      context 'when we drag item forwards' do
        let(:old_index) { 0 }
        let(:new_index) { 2 }
        let(:expected_order) { %w(2 3 1 4 5) }

        it_behaves_like 'drags successfully'
      end

      context 'when we drag item backwards' do
        let(:old_index) { 2 }
        let(:new_index) { 0 }
        let(:expected_order) { %w(3 1 2 4 5) }

        it_behaves_like 'drags successfully'
      end
    end
  end
end
