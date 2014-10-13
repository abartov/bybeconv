class ProofController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app
  before_filter :require_editor, :only => [:list, :show, :resolve]

  def create
    @p = Proof.new(:from => params['email'], :about => params['about'] || request.env["HTTP_REFERER"] || 'none', :what => params['what'], :subscribe => (params['subscribe'] == "yes" ? true : false), :status => 'new')
    h = HtmlFile.find_by_url(@p.about.sub(/https?:\/\/.*benyehuda.org\//, ''))
    @p.html_file = h unless h.nil?
    @p.save!
  end
  def index
    redirect_to :action => :list
  end
  def list
    # calculate tallies
    @count = { :all => Proof.count, :open => Proof.where(status: 'new').count, :resolved => Proof.where(status: 'resolved').count, :wontfix => Proof.where(status: 'wontfix').count }
    if params[:status].nil?
      @proofs = Proof.page(params[:page]) 
    else
      @proofs = Proof.where(status: params[:status]).page(params[:page])
    end
  end

  def show
    @p = Proof.find(params[:id])
  end

  def resolve
    @p = Proof.find(params[:id])
    if params[:fixed] == 'yes'
      @p.status = 'resolved'
    else
      @p.status = 'wontfix'
    end
    @p.resolved_by = session[:user]
    @p.save!
    redirect_to :action => :list, notice: t(:resolved_as, :fixed => (params[:fixed] == 'yes' ? 'תוקן' : 'כבר תקין'))
  end

end
