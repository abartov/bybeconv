# frozen_string_literal: true

module Admin
  # Controller to work with FeaturedContent records
  class FeaturedContentsController < ApplicationController
    before_action :require_editor
    before_action :set_featured_content, only: %i(show edit update destroy)

    def index
      @fcs = FeaturedContent.page(params[:page])
    end

    def new
      @fc = FeaturedContent.new
    end

    def create
      @fc = FeaturedContent.new(fc_params)
      @fc.user = current_user

      if @fc.save
        redirect_to admin_featured_content_path(@fc), notice: t(:created_successfully)
      else
        render :new, status: :unprocessable_content
      end
    end

    def show; end

    def edit; end

    def update
      # We have few legacy records in DB where `user` is null, and it caused validation failures during update
      # To avoid this, we set user to current_user if it is empty
      @fc.user = current_user if @fc.user.nil?

      if @fc.update(fc_params)
        flash.notice = I18n.t(:updated_successfully)
        redirect_to admin_featured_content_path(@fc)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @fc.destroy!
      flash.notice = I18n.t(:deleted_successfully)
      redirect_to admin_featured_contents_path
    end

    private

    def set_featured_content
      @fc = FeaturedContent.find(params[:id])
    end

    def fc_params
      params[:featured_content].permit(:title, :body, :external_link, :authority_id, :manifestation_id)
    end
  end
end
