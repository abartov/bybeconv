class RecommendationController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app
  before_filter :require_editor, :only => [:list, :show, :resolve]

  def create
    @p = Recommendation.new(:from => params['email'], :about => params['about'] || request.env["HTTP_REFERER"] || 'none', :what => params['what'], :subscribe => (params['subscribe'] == "yes" ? true : false), :status => 'new')
    h = HtmlFile.find_by_url(@p.about.sub(/https?:\/\/.*benyehuda.org\//, ''))
    @p.html_file = h unless h.nil?
    @p.save!
  end
  def index
    redirect_to :action => :list
  end
  def list
    # calculate tallies
    @count = { :all => Recommendation.count, :open => Recommendation.where(status: 'new').count, :accepted => Recommendation.where(status: 'accepted').count, :rejected => Recommendation.where(status: 'rejected').count }
    if params[:status].nil?
      @recs = Recommendation.page(params[:page]) 
    else
      @recs = Recommendation.where(status: params[:status]).page(params[:page])
    end
  end

  def show
    @p = Recommendation.find(params[:id])
  end

  def resolve
    @p = Recommendation.find(params[:id])
    if params[:accept] == 'yes'
      @p.status = 'accepted'
    else
      @p.status = 'rejected'
    end
    @p.resolved_by = session[:user]
    @p.save!
    flash[:notice] = t(:resolved_as, :fixed => (params[:accept] == 'yes' ? 'אושר' : 'נדחה'))
    redirect_to :action => :list
  end
  def purge
    Recommendation.where(status: 'rejected').delete_all
    flash[:notice] = t(:purged)
    redirect_to :action => :list
  end
end
