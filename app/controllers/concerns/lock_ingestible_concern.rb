# frozen_string_literal: true

# Logic to lock Ingestible object, to be included in related controllers
module LockIngestibleConcern
  extend ActiveSupport::Concern

  def try_to_lock_ingestible
    return if @ingestible.obtain_lock(current_user)

    respond_to do |format|
      flash.alert = t('ingestibles.ingestible_locked', user: @ingestible.locked_by_user.name)

      format.html { redirect_to ingestibles_path }
      format.js { render js: "window.location.href = '#{ingestibles_path}';" }
    end
  end
end
