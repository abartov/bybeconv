class PublicationsController < ApplicationController
  before_filter :require_editor
  before_action :set_publication, only: [:show, :edit, :update, :destroy]

  # GET /publications
  # GET /publications.json
  def index
    @publications = publication.all
  end

  # GET /publications/1
  # GET /publications/1.json
  def show
  end

  # GET /publications/new
  def new
    @publication = publication.new
  end

  # GET /publications/1/edit
  def edit
  end

  # POST /publications
  # POST /publications.json
  def create
    @pub = Publication.new(publication_params)
    bs = BibSource.where(title: params[:publication][:bib_source].strip)
    unless bs.empty?
      @pub.bib_source = bs[0]
    end
    respond_to do |format|
      if @pub.save
        format.html { redirect_to @pub, notice: 'Publication was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @pub }
      else
        format.html { render :new }
        format.json { render json: @pub.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /publications/1
  # PATCH/PUT /publications/1.json
  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.html { redirect_to @publication, notice: 'publication was successfully updated.' }
        format.json { render :show, status: :ok, location: @publication }
      else
        format.html { render :edit }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publications/1
  # DELETE /publications/1.json
  def destroy
    @publication.destroy
    respond_to do |format|
      format.html { redirect_to publications_url, notice: 'publication was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
  def set_publication
    @pub = Publication.find(params[:id])
  end
  def publication_params
    params.require(:publication).permit(:title, :publisher_line, :author_line, :notes, :source_id, :person_id, :status, :pub_year, :language)
  end
end
