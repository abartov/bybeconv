class HoldingsController < ApplicationController
  before_filter :require_editor
  before_action :set_holding, only: [:show, :edit, :update, :destroy]

  # GET /holdings
  # GET /holdings.json
  def index
    @holdings = Holding.all
  end

  # GET /holdings/1
  # GET /holdings/1.json
  def show
  end

  # GET /holdings/new
  def new
    @holding = Holding.new
  end

  # GET /holdings/1/edit
  def edit
  end

  # POST /holdings
  # POST /holdings.json
  def create
    @holding = Holding.new(holding_params)
    bs = BibSource.where(title: params[:source_name].strip)
    unless bs.empty?
      @holding.bib_source = bs[0]
    end
    respond_to do |format|
      if @holding.save
        format.html { redirect_to @holding, notice: 'holding was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @holding }
      else
        format.html { render :new }
        format.json { render json: @holding.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /holdings/1
  # PATCH/PUT /holdings/1.json
  def update
    respond_to do |format|
      if @holding.update(holding_params)
        format.html { redirect_to @holding, notice: 'holding was successfully updated.' }
        format.json { render :show, status: :ok, location: @holding }
      else
        format.html { render :edit }
        format.json { render json: @holding.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /holdings/1
  # DELETE /holdings/1.json
  def destroy
    @holding.destroy
    respond_to do |format|
      format.html { redirect_to holdings_url, notice: 'holding was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
  def set_holding
    @holding = Holding.find(params[:id])
  end
  def holding_params
    params.require(:holding).permit(:publication_id, :source_id, :scan_url, :status)
  end
end
