# frozen_string_literal: true

# Controller to work with Collections.
# Most of the actions require editor's permissions
class CollectionsController < ApplicationController
  before_action :require_editor, except: %i(show download print)
  before_action :set_collection, only: %i(show edit update destroy)

  # GET /collections or /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1 or /collections/1.json
  def show
    @header_partial = 'shared/collection_top'
    @scrollspy_target = 'chapternav'
    @colls_traversed = [@collection.id]
    @print_url = url_for(action: :print, collection_id: @collection.id)
    @pagetype = :collection
    @taggings = @collection.taggings
    @included_recs = @collection.included_recommendations.count
    @total_recs = @collection.recommendations.count + @included_recs
    prep_for_show
    prep_user_content(:collection) # user anthologies, bookmarks
  end

  # GET /collections/1/periodical_issues
  def periodical_issues
    @collection = Collection.find(params[:collection_id])
    render json: { issues: @collection.coll_items.where(collection_type: 'periodical_issue') }
  end

  def add_periodical_issue
    @collection = Collection.find(params[:collection_id])
    @issue = Collection.create!(title: params[:title], sort_title: params[:title], collection_type: 'periodical_issue')
    @collection.involved_authorities.each do |ia| # copy authorities from parent collection as defaults
      @issue.involved_authorities.create!(authority_id: ia.authority.id, role: ia.role)
    end
    @collection.append_item(@issue)
  end

  # GET /collections/1/download
  def download
    @collection = Collection.find(params[:collection_id])
    format = params[:format]
    unless Downloadable.doctypes.include?(format)
      flash[:error] = t(:unrecognized_format)
      redirect_to @collection
      return
    end

    dl = @collection.fresh_downloadable_for(format)
    if dl.nil?
      prep_for_show # TODO
      # impressionist(@m) unless is_spider? # TODO: enable impressionist for collections
      filename = "#{@collection.title.gsub(/[^0-9א-תA-Za-z.\-]/, '_')}.#{format}"
      html = <<~WRAPPER
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="he" lang="he" dir="rtl">
        <head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head>
        <body dir='rtl' align='right'><div dir="rtl" align="right">
        <div style="font-size:300%; font-weight: bold;">#{@collection.title}</div>
        #{@htmls.map { |h| "<h1>#{h[0]}</h1>\n#{I18n.t(:by)}<h2>#{h[1].map { |p| "<a href=\"/author/#{p.id}\">#{p.name}</a>" }.join(', ')}</h2>#{h[2]}" }.join("\n").force_encoding('UTF-8')}

        <hr />
        #{I18n.t(:download_footer_html, url: url_for(@collection))}
        </div></body></html>
      WRAPPER
      austr = textify_authorities_and_roles(@collection.involved_authorities)
      dl = MakeFreshDownloadable.call(params[:format], filename, html, @collection, austr)
    end
    redirect_to rails_blob_url(dl.stored_file, disposition: :attachment)
  end

  # GET /collections/1/print
  def print
    @print = true
    @collection = Collection.find(params[:collection_id])
    prep_for_show
    @footer_url = url_for(@collection)
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

    if @collection.save
      if params['authority'].present? && params['authority']['id'].present? && params['authority']['role'].present?
        @collection.involved_authorities.create!(authority_id: params['authority']['id'].to_i,
                                                 role: params['authority']['role'])
      end
      # redirect_to collection_url(@collection), notice: t(:created_successfully)
      render json: @collection
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    if @collection.update(collection_params)
      redirect_to collection_url(@collection), notice: t(:updated_successfully)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy

    redirect_to collections_url, notice: t(:deleted_successfully)
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

  def prep_for_show
    @htmls = []
    i = 1
    if @collection.periodical? # we don't want to show an entire periodical's run in a single Web page; instead, we show the complete TOC of all issues
      @collection.collection_items.each do |ci|
        next unless ci.item.present? && ci.item_type == 'Collection' && ci.item.collection_type == 'periodical_issue'
        html = ci.item.toc_html
        @htmls << [ci.item.title, ci.item.editors, html, false, ci.genre, i, ci]
      end
    else
      @collection.collection_items.each do |ci|
        html = ci.to_html
        #next unless html.present?
        @htmls << [ci.title, ci.authors, html.present? ? footnotes_noncer(ci.to_html, i) : '', false, ci.genre,
                  i, ci]
        i += 1
      end
    end
    @collection_total_items = @collection.collection_items.reject { |ci| ci.item_type == 'paratext' }.count
    @collection_minus_placeholders = @collection.collection_items.reject { |ci| ci.item.nil? }.count
    @authority_for_image = if @collection.authors.present?
                             @collection.authors.first
                           elsif @collection.translators.present?
                             @collection.translators.first
                           elsif @collection.editors.present?
                             @collection.editors.first
                           else
                             Authority.new(name: '')
                           end
  end
end
