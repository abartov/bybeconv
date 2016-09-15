class ManifestationController < ApplicationController
  before_filter :require_editor, only: [:edit, :update]
  def read
    @m = Manifestation.find(params[:id])
  end

  def list
    # calculations
    @total = Manifestation.count
    # form input
    unless params[:commit].blank?
      session[:mft_q_params] = params # make prev. params accessible to view
    else
      session[:mft_q_params] = { title: '', author: '' }
    end

    # DB
    p = params[:path]
    if p.blank?
      @manifestations = Manifestation.page(params[:page]).order('title ASC')
    else
      @manifestations = Manifestation.where('path like ?', '%' + p + '%').page(params[:page]).order('title ASC')
    end
  end

  def show
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!

  end

  def render_html
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def edit
  end

end
