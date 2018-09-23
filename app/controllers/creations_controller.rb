class CreationsController < ApplicationController
  before_action :require_editor
  def add # actually handled in Manifestation#update for now (AJAX some day?)
  end

  def remove
    c = Creation.find(params[:id])
    if c.nil?
      flash[:error] = t(:no_such_item)
    else
      c.destroy!
      flash[:notice] = t(:deleted_successfully)
    end
    redirect_to url_for(controller: :manifestation, action: :show, id: params[:manifestation_id])
  end
end
