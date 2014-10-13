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
    list
  end
  def list
    # calculate tallies
    @count = { :all => Proof.count, :open => Proof.count(status: 'new'), :resolved => Proof.count(status: 'resolved'), :wontfix => Proof.count(status: 'wontfix') }
    if params[:status].nil?
      @proofs = Proof.all.page(params[:page]) 
    else
      @proofs = Proof.where(status: params[:status]).page(params[:page])
    end
  end

  def show
    @p = Proof.find(params[:id])
  end

  def resolve(fixed)
    @p = Proof.find(params[:id])
    if params[:fixed] == 'yes'
      @p.status = 'resolved'
    else
      @p.status = 'wontfix'
    end
    @p.resolved_by = session[:user]
    @p.save!
    redirect_to :list, notice: t(:resolved_as, fixed => (params[:fixed] ? 'תוקן' : 'כבר תקין'))
  end

end
