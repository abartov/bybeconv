class BibSourcesController < ApplicationController
  before_action :set_bib_source, only: [:show, :edit, :update, :destroy]
  before_action :set_options_and_settings, only: [:new, :edit]

  # GET /bib_sources
  def index
    @bib_sources = BibSource.all
  end

  # GET /bib_sources/1
  def show
  end

  # GET /bib_sources/new
  def new
    @bib_source = BibSource.new
  end

  # GET /bib_sources/1/edit
  def edit
  end

  # POST /bib_sources
  def create
    @bib_source = BibSource.new(bib_source_params)

    if @bib_source.save
      redirect_to @bib_source, notice: 'Bib source was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bib_sources/1
  def update
    if @bib_source.update(bib_source_params)
      redirect_to @bib_source, notice: 'Bib source was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bib_sources/1
  def destroy
    @bib_source.destroy
    redirect_to bib_sources_url, notice: 'Bib source was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bib_source
      @bib_source = BibSource.find(params[:id])
    end

    def set_options_and_settings
      # set up which fields are needed for different source types (according to the Gared gem)
      @options = {
        aleph: { typename: t(:aleph), enable: [:url, :port, :institution, :item_pattern]},
        primo:{ typename: t(:primo), enable: [:url, :institution, :item_pattern]},
        idea: { typename: t(:idea), enable: [:url, :item_pattern]},
        hebrewbooks: { typename: t(:hebrewbooks), enable: []},
        googlebooks: { typename: t(:googlebooks), enable: [:api_key]}}.to_json
      typenames = [:aleph, :primo, :idea, :hebrewbooks, :googlebooks]
      @select_options = typenames.map{|tn| [t(tn), tn]}
    end

    # Only allow a trusted parameter "white list" through.
    def bib_source_params
      params.require(:bib_source).permit(:title, :source_type, :institution, :status, :url, :port, :api_key, :comments, :item_pattern)
    end
end
