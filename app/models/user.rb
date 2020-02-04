class User < ApplicationRecord
  # attr_accessible :email, :name, :oauth_expires_at, :oauth_token, :provider, :uid
  has_attached_file :avatar, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates :name, :provider, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false}, allow_blank: true #, on: :create

  has_and_belongs_to_many :liked_works, join_table: :work_likes, class_name: :Manifestation

  has_many :recommendations
  # no apparent need to be able to retrieve all recommendations a particular (admin) user has *resolved*.  If one arises, use a separate association on the resolved_by foreign key

  # editor bits
  EDITOR_BITS = ['handle_proofs', 'handle_recommendations', 'curate_featured_content', 'bib_workshop', 'edit_catalog', 'legacy_metadata', 'edit_people', 'conversion_verification', 'edit_sitenotice']

  ### User Preferences
  property_set :preferences do
    property :fontsize, default: '2'
    property :volunteer, default: 'false' # boolean  (another option - :protected => true)
    property :activated, default: 'false' # boolean
  end

  def admin?
    admin
  end

  def editor?
    editor
  end

  def has_bit?(bit)
    li = ListItem.where(listkey: bit, item: self).first
    return (not li.nil?)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
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
