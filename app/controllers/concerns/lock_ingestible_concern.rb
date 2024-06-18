# frozen_string_literal: true

# Logic to lock Ingestible object, to be included in related controllers
module LockIngestibleConcern
  extend ActiveSupport::Concern

  def try_to_lock_ingestible
    return if @ingestible.obtain_lock(current_user)

    redirect_to ingestibles_path,
                alert: t('.ingestible_locked', user: @ingestible.locked_by_user.name)
  end
end
