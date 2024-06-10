# frozen_string_literal: true

class CollectionsController < ApplicationController
  before_action :require_editor, except: %i(show)
  before_action :set_collection, only: %i(show edit update destroy)

  # GET /collections or /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1 or /collections/1.json
  def show
    @header_partial = 'shared/collection_top'
    @colls_traversed = [@collection.id]
    # @print_url = url_for(action: :print, id: @collection.id)
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit; end

  # POST /collections or /collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collection_url(@collection), notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to collection_url(@collection), notice: 'Collection was successfully updated.' }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /collections/1/apply_drag
  def apply_drag
    @collection = Collection.find(params[:collection_id])
    if @collection.nil?
      flash[:error] = t(:no_such_item)
      head :not_found
    else
      if params[:coll_item_id].present? && params[:old_pos].present? && params[:new_pos].present?
        @collection.apply_drag(params[:coll_item_id].to_i, params[:old_pos].to_i,
                               params[:new_pos].to_i)
      end
      head :ok
    end
  end

  # POST /collections/1/transplant_item
  def transplant_item
    @collection = Collection.find(params[:collection_id])
    @dest_coll = Collection.find(params[:dest_coll_id].to_i)
    @src_coll = Collection.find(params[:src_coll_id].to_i)
    @item = CollectionItem.find(params[:item_id].to_i)
    if @dest_coll.nil? || @src_coll.nil? || @item.nil?
      flash[:error] = t(:no_such_item)
      head :not_found
      return
    end
    ActiveRecord::Base.transaction do
      @dest_coll.insert_item_at(@item, params[:new_pos].to_i)
      @src_coll.remove_item(@item)
    end
    head :ok
  end

  def manage
    @collection = Collection.find(params[:collection_id])
    if @collection.nil?
      flash[:error] = t(:no_such_item)
      redirect_to admin_index_path
    elsif @collection.root? # switch to side-by-side view with legacy author TOC for root collections (for now)
      @author = Authority.find_by(root_collection_id: @collection.id)
      if @author.present?
        redirect_to authors_manage_toc_path(id: @author.id)
        return
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def collection_params
    params.require(:collection).permit(:title, :sort_title, :subtitle, :issn, :collection_type, :inception,
                                       :inception_year, :publication_id, :toc_id, :toc_strategy)
  end
end
