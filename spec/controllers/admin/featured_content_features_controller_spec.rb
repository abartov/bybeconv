# frozen_string_literal: true

require 'rails_helper'

describe Admin::FeaturedContentFeaturesController do
  include_context 'when editor logged in'

  let!(:featured_content) { create(:featured_content) }

  describe '#create' do
    subject(:call) do
      post :create, params: { featured_content_id: featured_content.id, featured_content_feature: feature_params }
    end

    context 'when params are invalid' do
      let(:feature_params) { { from_date: nil, to_date: nil } }

      it 'displays alert and redirects to featured content page' do
        expect { call }.not_to change(FeaturedContentFeature, :count)
        expect(call).to redirect_to admin_featured_content_path(featured_content)
        expect(flash.alert).to eq I18n.t('admin.featured_content_features.create.failed')
      end
    end

    context 'when params are valid' do
      let(:feature_params) { { fromdate: 5.days.ago.to_date, todate: 2.days.from_now.to_date } }

      it 'creates record and redirects to featured content page' do
        expect { call }.to change(FeaturedContentFeature, :count).by(1)
        feature = FeaturedContentFeature.order(id: :desc).first
        expect(feature).to have_attributes(feature_params)
        expect(call).to redirect_to admin_featured_content_path(featured_content)
        expect(flash.notice).to eq I18n.t(:created_successfully)
      end
    end
  end

  describe '#destroy' do
    subject(:call) { delete :destroy, params: { id: featured_content_feature.id } }

    let!(:featured_content_feature) { create(:featured_content_feature, featured_content: featured_content) }

    it 'deletes record and redirects to featured content show page' do
      expect { call }.to change(FeaturedContentFeature, :count).by(-1)
      expect(call).to redirect_to admin_featured_content_path(featured_content)
      expect(flash.notice).to eq I18n.t(:deleted_successfully)
    end
  end
end
