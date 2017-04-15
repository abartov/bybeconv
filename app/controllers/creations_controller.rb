class CreationsController < ApplicationController
  def add
    c = Creation.new(work_id: params[:work_id], person_id: params[:person_id], role: params[:role])
    c.save!
    redirect_to url_for(controller: :manifestation, action: :show, id: params[:manifestation_id])
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
