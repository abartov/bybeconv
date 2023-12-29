class CollectionItemsController < ApplicationController
  before_action :set_collection_item, only: %i[ show edit update destroy ]

  # GET /collection_items or /collection_items.json
  def index
    @collection_items = CollectionItem.all
  end

  # GET /collection_items/1 or /collection_items/1.json
  def show
  end

  # GET /collection_items/new
  def new
    @collection_item = CollectionItem.new
  end

  # GET /collection_items/1/edit
  def edit
  end

  # POST /collection_items or /collection_items.json
  def create
    @collection_item = CollectionItem.new(collection_item_params)

    respond_to do |format|
      if @collection_item.save
        format.html { redirect_to collection_item_url(@collection_item), notice: "Collection item was successfully created." }
        format.json { render :show, status: :created, location: @collection_item }
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
        format.html { redirect_to collection_item_url(@collection_item), notice: "Collection item was successfully updated." }
        format.json { render :show, status: :ok, location: @collection_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_items/1 or /collection_items/1.json
  def destroy
    @collection_item.destroy

    respond_to do |format|
      format.html { redirect_to collection_items_url, notice: "Collection item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_item
      @collection_item = CollectionItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_item_params
      params.require(:collection_item).permit(:collection_id, :alt_title, :context, :seqno, :item_id, :item_type)
    end
end
