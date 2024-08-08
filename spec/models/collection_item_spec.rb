# frozen_string_literal: true

require 'rails_helper'

describe CollectionItem do
  describe 'Validations' do
    subject(:result) { collection_item.valid? }

    let(:collection_item) { build(:collection_item, collection: collection, item: item) }
    let(:collection) { create(:collection) }

    describe '#ensure_no_cycles' do
      context 'when item is an Manifestation' do
        let(:item) { create(:manifestation) }

        it { is_expected.to be_truthy }
      end

      shared_examples 'fails if cycle is found' do
        it 'fails due to cycle' do
          expect(result).to be false
          expect(collection_item.errors[:collection]).to eq [
            I18n.t('activerecord.errors.models.collection_item.attributes.collection.cycle_found')
          ]
        end
      end

      context 'when item is a collection' do
        context 'when item is the same collection' do
          let(:item) { collection }

          it_behaves_like 'fails if cycle is found'
        end

        context 'when item is another collection' do
          let(:item) { create(:collection) }

          before do
            create(:collection_item, collection: item, item: create(:collection))
          end

          context 'when there is no cycle' do
            it { is_expected.to be_truthy }
          end

          context 'when there is a cycle' do
            before do
              create(:collection_item, collection: item, item: collection)
            end

            it_behaves_like 'fails if cycle is found'
          end
        end
      end
    end
  end
end
