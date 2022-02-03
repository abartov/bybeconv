class PreferencesController < ApplicationController
  def update
    bu = base_user(true)
    pref = params.require(:id)
    value = params.require(:value)
    bu.set_preference(pref, value)
    render json: { head: :ok }
  end
end
