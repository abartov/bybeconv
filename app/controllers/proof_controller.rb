class ProofController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app
  before_filter :require_editor, :only => [:list, :show, :resolve, :purge]

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
      @proofs = Proof.where('status != "spam"').page(params[:page]) 
    else
      @proofs = Proof.where(status: params[:status]).page(params[:page])
    end
  end

  def show
    @p = Proof.find(params[:id])
    @p.what = '' if @p.what.nil?
  end
  def resolve
    fix_text = ''
    @p = Proof.find(params[:id])
    if params[:fixed] == 'yes'
      @p.status = 'resolved'
      unless @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        Notifications.proof_fixed(@p, @p.about).deliver
      end
      fix_text = 'תוקן )ונשלח דואל('
    elsif params[:fixed] == 'no'
      @p.status = 'wontfix'
      unless @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        Notifications.proof_wontfix(@p, @p.about).deliver
      end
      fix_text = 'כבר תקין )ונשלח דואל('
    else # spam, just ignore
      @p.status = 'spam'
      fix_text = 'זבל'
    end
    @p.resolved_by = session[:user]
    @p.save!
    flash[:notice] = t(:resolved_as, :fixed => fix_text)
    redirect_to :action => :list
  end
  def purge
    Proof.where(status: 'spam').delete_all
    flash[:notice] = t(:purged)
    redirect_to :action => :list
  end
end
