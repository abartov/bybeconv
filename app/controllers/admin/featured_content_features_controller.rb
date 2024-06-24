# frozen_string_literal: true

module Admin
  # Controller to work with FeaturedContentFeature records
  class FeaturedContentFeaturesController < ApplicationController
    before_action :require_editor

    def create
      fc = FeaturedContent.find(params[:featured_content_id])
      feature = fc.featured_content_features.build(featured_content_feature_params)
      if feature.save
        flash.notice = t(:created_successfully)
      else
        flash.alert = t('.failed')
      end

      redirect_to admin_featured_content_path(fc)
    end

    def destroy
      fcf = FeaturedContentFeature.find(params[:id])
      fc_id = fcf.featured_content_id
      fcf.destroy!
      redirect_to admin_featured_content_path(fc_id), notice: t(:deleted_successfully)
    end

    private

    def featured_content_feature_params
      params.require(:featured_content_feature).permit(:fromdate, :todate)
    end
  end
end
