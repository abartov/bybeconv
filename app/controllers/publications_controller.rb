class PublicationsController < ApplicationController
  before_filter :require_editor
  before_action :set_publication, only: [:show, :edit, :update, :destroy]

  # GET /publications
  # GET /publications.json
  def index
    @publications = Publication.order(status: :asc).page(params[:page])
  end

  # GET /publications/1
  # GET /publications/1.json
  def show
  end

  # GET /publications/new
  def new
    @publication = Publication.new
  end

  # GET /publications/1/edit
  def edit
  end

  # POST /publications
  # POST /publications.json
  def create
    pub_params = publication_params
    location = pub_params.delete(:callnum)
    @pub = Publication.new(pub_params)
    sid = (@pub.source_id.class == Array ? @pub.source_id[0] : @pub.source_id)
    @pub.source_id = sid
    @holding = Holding.new(source_id: sid)
    @holding.location = location
    bs = BibSource.where(title: params[:publication][:bib_source].strip)
    unless bs.empty?
      @pub.bib_source = bs[0]
      @holding.bib_source = bs[0]
    end
    @holding.status = status_by_source_type(@pub.bib_source.source_type)
    if @holding.status == Holding.statuses[:scanned]
      @holding.scan_url = @pub.source_id # TODO: improve
    end
    @pub.holdings << @holding
    respond_to do |format|
      if @pub.save && @holding.save
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
        format.js
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
      format.js
      format.json { head :no_content }
    end
  end

  private
  def set_publication
    @publication = Publication.find(params[:id])
  end
  def status_by_source_type(stype)
    # TODO: add handling of Primo e-resources once those become available at NLI
    case stype
    when BibSource.source_types[:hebrewbooks], BibSource.source_types[:googlebooks]
      return 'scanned'
    else
      return 'todo'
    end
  end
  def publication_params
    params.require(:publication).permit(:title, :publisher_line, :author_line, :notes, :source_id, :person_id, :status, :pub_year, :language, :callnum)
  end
end
