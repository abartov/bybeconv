class User < ActiveRecord::Base
  attr_accessible :email, :name, :oauth_expires_at, :oauth_token, :provider, :uid

  has_many :recommendations, foreign_key: :recommended_by
  # no apparent need to be able to retrieve all recommendations a particular (admin) user has *resolved*.  If one arises, use a separate association on the resolved_by foreign key

  ### User Preferences
  property_set :preferences do
    property :fontsize, default: 2
    property :volunteer, default: false # boolean  (another option - :protected => true)
    property :activated, default: false # boolean
  end

  def admin?
    admin
  end

  def editor?
    editor
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) unless auth.credentials.expires_at.nil?
      user.admin = false if user.admin.nil?
      user.editor = false if user.editor.nil?
      user.save!
    end
  end
end
