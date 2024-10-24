# frozen_string_literal: true

class CollectionItemsController < ApplicationController
  before_action :set_collection_item, only: %i(show edit update destroy)

  # GET /collection_items/1 or /collection_items/1.json
  def show; end

  # GET /collection_items/new
  def new
    @collection_item = CollectionItem.new
  end

  # GET /collection_items/1/edit
  def edit; end

  # POST /collection_items or /collection_items.json
  # called from _manage_collection_items.html.haml
  def create
    success = true
    @collection_item = CollectionItem.new(collection_item_params)
    if params[:collection_item][:item_id].blank?
      unless params[:collection_item][:item_type] == 'Manifestation' # can't create manifestations from here
        if params[:collection_item][:item_type] == 'paratext'
          @collection_item.markdown = @collection_item.alt_title
          @collection_item.alt_title = nil
        elsif params[:collection_item][:item_type] == 'placeholder_item'
          @collection_item.item_id = nil
          @collection_item.item_type = nil
        else
          c = Collection.create!(title: params[:collection_item][:alt_title],
                                 collection_type: params[:collection_item][:item_type])
          @collection_item.item = c # this overrides the passed item_type which is actually collection_type
          @collection_item.alt_title = nil
        end
      else
        success = false
      end
    end
    @collection_id = params[:collection_item][:collection_id]
    @collection = Collection.find(@collection_id)
    @collection_item.seqno = @collection.collection_items.maximum(:seqno).to_i + 1 unless @collection.nil?
    @colls_traversed = []
    success = @collection_item.save if success
    respond_to do |format|
      if success
        format.html do
          redirect_to collection_item_url(@collection_item), notice: t(:created_successfully)
        end
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_items/1 or /collection_items/1.json
  def update
    respond_to do |format|
      if @collection_item.update(collection_item_params)
        @element_id = "#editable_#{@collection_item.id}"
        @html = MultiMarkdown.new(@collection_item.markdown).to_html if params[:collection_item][:markdown].present?
        @title_id = "#ci_title_#{@collection_item.id}"
        @title = @collection_item.alt_title
        format.html do
          redirect_to collection_item_url(@collection_item), notice: 'Collection item was successfully updated.'
        end
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_items/1 or /collection_items/1.json
  def destroy
    @collection = @collection_item.collection
    @deleted_id = @collection_item.id # used in the js response
    @collection_item.destroy

    respond_to do |format|
      format.html { redirect_to collection_manage_path(@collection.id), notice: t(:deleted_successfully) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collection_item
    @collection_item = CollectionItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def collection_item_params
    params.require(:collection_item).permit(:collection_id, :alt_title, :context, :seqno, :item_id, :item_type,
                                            :markdown)
  end
end
