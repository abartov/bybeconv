# Model to represent all users of system: both authenticated and not-authenticated
# If user is authenticated we link this record to User model, otherwise we link it to session
class BaseUser < ApplicationRecord
  belongs_to :user, inverse_of: :base_user, optional: true

  # This record must be identified either by user_id or by session_id, but not by both
  validates_absence_of :session_id, if: -> { self.user_id.present? }
  validates_presence_of :session_id, if: -> { self.user_id.nil? }
end
