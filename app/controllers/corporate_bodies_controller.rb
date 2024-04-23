# frozen_string_literal: true

class CorporateBodiesController < ApplicationController
  before_action do |c| c.require_editor('edit_people') end

  before_action :set_corporate_body, only: %i[show edit update destroy corp_toc]

  ATTRIBUTES_TO_SHOW = %i[
    name
    alternate_names
    status
    country
    location
    inception
    inception_year
    dissolution
    dissolution_year
    wikidata_uri
    wikipedia_url
    wikipedia_snippet
    viaf_id
    nli_id
    comments
  ].freeze

  # GET /corporate_bodies or /corporate_bodies.json
  def index
    @corporate_bodies = CorporateBody.all
  end

  # GET /corporate_bodies/1 or /corporate_bodies/1.json
  def show; end

  def corp_toc
    if @corporate_body.nil?
      flash[:error] = I18n.t(:no_toc_yet)
      redirect_to '/'
    elsif @corporate_body.published?
      @tabclass = set_tab('authors')
      @print_url = corp_print_path(id: @corporate_body.id)
      @pagetype = :author
      @header_partial = 'authors/author_top'
      @entity = @corporate_body
      @page_title = "#{@corporate_body.name} - #{t(:table_of_contents)} - #{t(:project_ben_yehuda)}"

      @og_image = @corporate_body.profile_image.url(:thumb)
      @latest = cached_textify_titles(@corporate_body.cached_latest_stuff, @corporate_body)
      # @featured = @corporate_body.featured_work
      @aboutnesses = @corporate_body.aboutnesses
      @external_links = @corporate_body.external_links.status_approved
      # @any_curated = @featured.present? || @aboutnesses.count > 0
      @any_curated = @aboutnesses.count.positive?
      # unless @featured.empty?
      #  (@fc_snippet, @fc_rest) = snippet(@featured[0].body, 500) # prepare snippet for collapsible
      # end
      @taggings = @corporate_body.taggings
      @author = @corporate_body # for generate_toc
      generate_toc
      prep_user_content(:author)
      @scrollspy_target = 'genrenav'
      render 'authors/toc'
    else
      flash[:error] = I18n.t(:author_not_available)
      redirect_to '/'
    end
  end

  # GET /corporate_bodies/new
  def new
    @corporate_body = CorporateBody.new(status: :unpublished)
  end

  # GET /corporate_bodies/1/edit
  def edit; end

  # POST /corporate_bodies or /corporate_bodies.json
  def create
    @corporate_body = CorporateBody.new(corporate_body_params)

    if @corporate_body.save
      redirect_to @corporate_body, notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /corporate_bodies/1 or /corporate_bodies/1.json
  def update
    if @corporate_body.update(corporate_body_params)
      redirect_to corporate_body_url(@corporate_body), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /corporate_bodies/1 or /corporate_bodies/1.json
  def destroy
    @corporate_body.destroy
    redirect_to corporate_bodies_url, notice: t('.success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_corporate_body
    @corporate_body = CorporateBody.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def corporate_body_params
    params.require(:corporate_body).permit(
      :name,
      :alternate_names,
      :status,
      :country,
      :location,
      :inception,
      :inception_year,
      :dissolution,
      :dissolution_year,
      :wikipedia_url,
      :wikipedia_snippet,
      :wikidata_uri,
      :viaf_id,
      :nli_id,
      :comments
    )
  end
end
