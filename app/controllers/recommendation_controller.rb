class RecommendationController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app
  before_filter :require_editor, :only => [:list, :show, :resolve]

  def create
    unless params['what'].nil? or params['what'].empty? or is_blacklisted_ip(request.remote_ip) # don't bother capturing null submissions and filter out spam
      @p = Recommendation.new(:from => params['email'], :about => params['about'] || request.env["HTTP_REFERER"] || 'none', :what => params['what'], :subscribe => (params['subscribe'] == "yes" ? true : false), :status => 'new')
      h = HtmlFile.find_by_url(@p.about.sub(/https?:\/\/.*benyehuda.org\//, ''))
      @p.html_file = h unless h.nil?
      @p.save!
    end
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
    @p.what = '' if @p.what.nil?
  end

  def resolve
    @p = Recommendation.find(params[:id])
    if params[:accept] == 'yes'
      @p.status = 'accepted'
      unless @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        Notifications.recommendation_accepted(@p, @p.about).deliver
      end
      text = 'ההמלצה התקבלה וממתיה לשילוב ביומן הרשת'
    elsif params[:accept] == 'no'
      @p.status = 'rejected'
      text = 'ההמלצה נדחתה ותימחק עם השאר'
    else
      @p.status = 'archived' 
      unless @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/ 
        Notifications.recommendation_blogged(@p, @p.about, params[:blog_url]).deliver # send "blogged" notice
      end
      text = 'ההמלצה אורכבה ונשלח דואל לממליץ/ה'
    end
    @p.resolved_by = session[:user]
    @p.save!
    flash[:notice] = t(:resolved_as, :fixed => text)
    redirect_to :action => :list
  end
  def purge
    Recommendation.where(status: 'rejected').delete_all
    flash[:notice] = t(:purged)
    redirect_to :action => :list
  end
end
