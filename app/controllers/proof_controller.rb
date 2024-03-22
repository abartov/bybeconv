class ProofController < ApplicationController
  protect_from_forgery :except => :submit # allow submission from outside the app
  before_action :only => [:index, :list, :show, :resolve, :purge] do |c| c.require_editor('handle_proofs') end

#  impressionist # log actions for pageview stats

  def create
    @errors = []
    unless params[:ziburit] =~ /ביאליק/
      @errors << I18n.t('proof.create.ziburit_failed')
    end
    if params[:from].blank?
      @errors << I18n.t('proof.create.email_missing')
    end

    if @errors.empty?
      Proof.create!(
        from: params[:from],
        manifestation_id: params['manifestation'].to_i,
        what: params[:what],
        highlight: params[:highlight],
        status: :new
      )
      head :ok
    else
      render json: @errors, status: :unprocessable_entity
    end
  end
  def index
    redirect_to :action => :list
  end
  def list
    # calculate tallies
    @count = { 'all' => Proof.count, 'new' => Proof.where(status: 'new').count, 'fixed' => Proof.where(status: 'fixed').count, 'wontfix' => Proof.where(status: 'wontfix').count, 'escalated' => Proof.where(status: 'escalated').count, 'spam' => Proof.where(status: 'spam').count }
    if params[:status].nil?
      @proofs = Proof.where('status != "spam"').page(params[:page]).order(:manifestation_id)
    else
      @proofs = Proof.where(status: params[:status]).page(params[:page]).order(:manifestation_id)
    end
  end

  def show
    @p = Proof.find(params[:id])
    @p.what = '' if @p.what.nil?
    if @p.manifestation
      @m = Manifestation.find(@p.manifestation_id)
    else
      h = HtmlFile.find_by_url(@p.about.sub(/http:\/\/benyehuda\.org/,''))
      unless h.nil?
        @m = h.manifestations[0] if h.status == 'Published'
      end
    end
    unless @m.nil?
      @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      @translation = @m.expression.translation
    else
      @html =''
    end
  end

  def resolve
    fix_text = ''
    @p = Proof.find(params[:id])
    if params[:fixed] == 'yes'
      @p.status = 'fixed'
      unless params[:email] == 'no' or @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        @explanation = params[:fixed_explanation]
        if @p.manifestation_id.nil?
          Notifications.proof_fixed(@p, @p.about, nil, @explanation).deliver
        else
          Notifications.proof_fixed(@p, manifestation_path(@p.manifestation_id), @p.manifestation, @explanation).deliver
        end
    		fix_text = 'תוקן (ונשלח דואל)'
      else
	      fix_text = 'תוקן, בלי לשלוח דואל'
      end
    elsif params[:fixed] == 'no'
      if params[:escalate] == 'yes'
        @p.status = 'escalated'
        fix_text = t(:escalated)
      else
      @p.status = 'wontfix'
      @explanation = params[:wontfix_explanation]
      unless @p.from.nil? or @p.from !~ /\w+@\w+\.\w+/
        if @p.manifestation_id.nil?
          Notifications.proof_wontfix(@p, @p.about, nil, @explanation).deliver
        else
          Notifications.proof_wontfix(@p, manifestation_path(@p.manifestation_id), @p.manifestation, @explanation).deliver
        end
      end
      fix_text = 'כבר תקין (ונשלח דואל)'
      end
    else # spam, just ignore
      @p.status = 'spam'
      fix_text = 'זבל'
    end
    @p.resolver = current_user
    @p.save!
    li = ListItem.where(listkey: 'proofs_by_user', item_id: @p.id)
    li.destroy_all unless li.nil? # unassign the proof from the user's list
    flash[:notice] = t(:resolved_as, :fixed => fix_text)
    if current_user.admin?
      redirect_to :action => :list, :status => 'new'
    else
      redirect_to controller: :admin
    end
  end
  def purge
    Proof.where(status: 'spam').delete_all
    flash[:notice] = t(:purged)
    redirect_to :action => :list
  end
end
