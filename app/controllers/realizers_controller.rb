class RealizersController < ApplicationController
  before_filter :require_editor

  def remove
    r = Realizer.find(params[:id])
    if r.nil?
      flash[:error] = t(:no_such_item)
    else
      r.destroy!
      flash[:notice] = t(:deleted_successfully)
    end
    redirect_to url_for(controller: :manifestation, action: :show, id: params[:manifestation_id])

  end
end
