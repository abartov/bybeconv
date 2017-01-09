class ProofController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app
  before_filter :require_editor, :only => [:index, :list, :show, :resolve, :purge]

  impressionist # log actions for pageview stats

  def create
    if params['manifestation'].nil? # legacy site's buttons.js hack
      unless params['what'].nil? or params['what'].empty? # don't bother capturing null submissions
        if is_blacklisted_ip(client_ip) # filter out spam
          render :nothing
        else
          @p = Proof.new(:from => params['email'], :about => params['about'] || request.env["HTTP_REFERER"] || 'none', :what => params['what'], :subscribe => (params['subscribe'] == "yes" ? true : false), :status => 'new')
          h = HtmlFile.find_by_url(@p.about.sub(/https?:\/\/.*benyehuda.org\//, ''))
          @p.html_file = h unless h.nil?
          @p.save!
        end
      end
    else # new BYBE
      @p = Proof.new(from: params['email'], manifestation_id: params['manifestation'].to_i, what: params['what'], highlight: params['highlight'], status: 'new')
      @p.save!
    end
    respond_to do |fmt|
      fmt.html { }
      fmt.js { flash[:notice] = I18n.t(:proof_thanks_html) }
    end
  end
  def index
    redirect_to :action => :list
  end
  def list
    # calculate tallies
    @count = { :all => Proof.count, :open => Proof.where(status: 'new').count, :resolved => Proof.where(status: 'resolved').count, :wontfix => Proof.where(status: 'wontfix').count }
    if params[:show_status].nil?
      @proofs = Proof.where('status != "spam"').page(params[:page]).order(:about)
    else
      @proofs = Proof.where(status: params[:show_status]).page(params[:page]).order(:about)
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
      unless params[:email] == 'no' or @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        Notifications.proof_fixed(@p, @p.about).deliver
		fix_text = 'תוקן (ונשלח דואל)'
      else
	    fix_text = 'תוקן, בלי לשלוח דואל'
      end
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
    redirect_to :action => :list, :show_status => 'new'
  end
  def purge
    Proof.where(status: 'spam').delete_all
    flash[:notice] = t(:purged)
    redirect_to :action => :list
  end
end
