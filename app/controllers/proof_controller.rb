class ProofController < ApplicationController

  protect_from_forgery :except => :submit # allow submission from outside the app

  def create
    @p = Proof.new(:from => params['email'], :about => params['about'] || request.env["HTTP_REFERER"] || 'none', :what => params['what'], :subscribe => (params['subscribe'] == "yes" ? true : false), :status => 'new')
    @p.save
  end

  def list
    @proofs = Proof.all # later query/differentiate by status
  end

  def show
    @p = Proof.find(params[:id])
  end

  def resolve
    @p = Proof.find(params[:id])
    @p.status = 'resolved'
    @p.assignee = session[:user]
    @p.save
  end

end
