class HtmlDirsController < ApplicationController
  include BybeUtils
  before_filter :require_admin

  # GET /html_dirs
  # GET /html_dirs.json
  def index
    unless params[:unassociated].nil?
      @html_dirs = HtmlDir.order('person_id ASC')
    else
      @html_dirs = HtmlDir.order('author ASC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @html_dirs }
    end
  end

  def guess_author
    @html_dir = HtmlDir.find(params[:id])
    @viaf_list = guess_authors_viaf(@html_dir.author)
    respond_to do |format|
      format.json { render json: @viaf_list }
    end
  end

  def associate_viaf
    @html_dir = HtmlDir.find(params[:id])
    person = Person.create_or_get_person_by_viaf(params[:viaf])
    @html_dir.person = person
    @html_dir.save!
    person.public_domain = @html_dir.public_domain
    person.save!
    redirect_to @html_dir, notice: t(:associated_with_viaf, viaf: params[:viaf])
  end
  # GET /html_dirs/1
  # GET /html_dirs/1.json
  def show
    @html_dir = HtmlDir.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @html_dir }
    end
  end

  # GET /html_dirs/new
  # GET /html_dirs/new.json
  def new
    @html_dir = HtmlDir.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @html_dir }
    end
  end

  # GET /html_dirs/1/edit
  def edit
    @html_dir = HtmlDir.find(params[:id])
  end

  # POST /html_dirs
  # POST /html_dirs.json
  def create
    @html_dir = HtmlDir.new(hd_params)

    respond_to do |format|
      if @html_dir.save
        format.html { redirect_to @html_dir, notice: 'Html dir was successfully created.' }
        format.json { render json: @html_dir, status: :created, location: @html_dir }
      else
        format.html { render action: 'new' }
        format.json { render json: @html_dir.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /html_dirs/1
  # PUT /html_dirs/1.json
  def update
    @html_dir = HtmlDir.find(params[:id])

    respond_to do |format|
      if @html_dir.update_attributes(hd_params)
        format.html { redirect_to @html_dir, notice: t(:updated_successfully) }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @html_dir.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /html_dirs/1
  # DELETE /html_dirs/1.json
  def destroy
    @html_dir = HtmlDir.find(params[:id])
    @html_dir.destroy

    respond_to do |format|
      format.html { redirect_to html_dirs_url }
      format.json { head :ok }
    end
  end

  private

  def hd_params
    params[:html_dir].permit(:public_domain, :author, :path)
  end
end
