# frozen_string_literal: true

module Admin
  # Controller to work with Authorities records
  class AuthoritiesController < ApplicationController
    before_action :require_editor

    before_action :set_authority, only: %i(refresh_uncollected_works_collection)

    def refresh_uncollected_works_collection
      RefreshUncollectedWorksCollection.call(@authority)
      redirect_to authority_path(@authority.id), notice: t(:updated_successfully)
    end

    private

    def set_authority
      @authority = Authority.find(params[:id])
    end
  end
end
