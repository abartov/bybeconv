class CorporateBodiesController < ApplicationController
  before_action :set_corporate_body, only: %i[ show edit update destroy ]

  # GET /corporate_bodies or /corporate_bodies.json
  def index
    @corporate_bodies = CorporateBody.all
  end

  # GET /corporate_bodies/1 or /corporate_bodies/1.json
  def show
  end

  # GET /corporate_bodies/new
  def new
    @corporate_body = CorporateBody.new
  end

  # GET /corporate_bodies/1/edit
  def edit
  end

  # POST /corporate_bodies or /corporate_bodies.json
  def create
    @corporate_body = CorporateBody.new(corporate_body_params)

    respond_to do |format|
      if @corporate_body.save
        format.html { redirect_to corporate_body_url(@corporate_body), notice: "Corporate body was successfully created." }
        format.json { render :show, status: :created, location: @corporate_body }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @corporate_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /corporate_bodies/1 or /corporate_bodies/1.json
  def update
    respond_to do |format|
      if @corporate_body.update(corporate_body_params)
        format.html { redirect_to corporate_body_url(@corporate_body), notice: "Corporate body was successfully updated." }
        format.json { render :show, status: :ok, location: @corporate_body }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @corporate_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /corporate_bodies/1 or /corporate_bodies/1.json
  def destroy
    @corporate_body.destroy

    respond_to do |format|
      format.html { redirect_to corporate_bodies_url, notice: "Corporate body was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_corporate_body
      @corporate_body = CorporateBody.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def corporate_body_params
      params.require(:corporate_body).permit(:name, :alternate_names, :location, :inception, :inception_year, :dissolution, :dissolution_year, :wikidata_uri, :viaf_id, :comments)
    end
end
