class InvolvedAuthoritiesController < ApplicationController
  before_action :set_involved_authority, only: %i[ show edit update destroy ]

  # GET /involved_authorities or /involved_authorities.json
  def index
    @involved_authorities = InvolvedAuthority.all
  end

  # GET /involved_authorities/1 or /involved_authorities/1.json
  def show
  end

  # GET /involved_authorities/new
  def new
    @involved_authority = InvolvedAuthority.new
  end

  # GET /involved_authorities/1/edit
  def edit
  end

  # POST /involved_authorities or /involved_authorities.json
  def create
    @involved_authority = InvolvedAuthority.new(involved_authority_params)

    respond_to do |format|
      if @involved_authority.save
        format.html { redirect_to involved_authority_url(@involved_authority), notice: "Involved authority was successfully created." }
        format.json { render :show, status: :created, location: @involved_authority }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @involved_authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /involved_authorities/1 or /involved_authorities/1.json
  def update
    respond_to do |format|
      if @involved_authority.update(involved_authority_params)
        format.html { redirect_to involved_authority_url(@involved_authority), notice: "Involved authority was successfully updated." }
        format.json { render :show, status: :ok, location: @involved_authority }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @involved_authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /involved_authorities/1 or /involved_authorities/1.json
  def destroy
    @involved_authority.destroy

    respond_to do |format|
      format.html { redirect_to involved_authorities_url, notice: "Involved authority was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_involved_authority
      @involved_authority = InvolvedAuthority.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def involved_authority_params
      params.require(:involved_authority).permit(:authority_id, :authority_type, :role, :item_id, :item_type)
    end
end
