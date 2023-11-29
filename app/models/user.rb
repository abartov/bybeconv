class User < ApplicationRecord
  # attr_accessible :email, :name, :oauth_expires_at, :oauth_token, :provider, :uid
  has_attached_file :avatar, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates :name, :provider, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false}, allow_blank: true #, on: :create

  has_and_belongs_to_many :liked_works, join_table: :work_likes, class_name: :Manifestation

  has_one :base_user, inverse_of: :user
  has_many :recommendations
  has_many :anthologies, dependent: :destroy
  has_many :taggings, foreign_key: 'suggested_by'
  has_many :blocks, class_name: :UserBlock, inverse_of: :user
  # no apparent need to be able to retrieve all recommendations a particular (admin) user has *resolved*.  If one arises, use a separate association on the resolved_by foreign key

  # editor bits
  EDITOR_BITS = ['handle_proofs', 'handle_recommendations', 'curate_featured_content', 'bib_workshop', 'edit_catalog', 'legacy_metadata', 'edit_people', 'conversion_verification', 'edit_sitenotice', 'moderate_tags']

  def admin?
    admin
  end

  def editor?
    editor
  end

  def crowdsourcer?
    crowdsourcer
  end

  def has_bit?(bit)
    li = ListItem.where(listkey: bit, item: self).first
    return (not li.nil?)
  end

  def tag_acceptance_rate
    tags = Tag.where(creator: self)
    return 0 if tags.count == 0
    (tags.where(status: :approved).count.to_f / tags.count.to_f).round(2)*100
  end

  def pending_tags
    Tag.where(creator: self, status: :pending)
  end

  def recent_tags_used(limit=10)
    Tag.joins(:taggings).where(taggings: {suggester: self}).group('tags.id').order('MAX(taggings.created_at) DESC').limit(limit)
  end

  def popular_tags_used(limit=10)
    Tag.find(popular_tags_used_with_count.keys.first(limit))
  end

  def popular_tags_used_with_count
    Tag.joins(:taggings).where(taggings: {suggester: self}).group('tags.id').order('count_all DESC').count
  end

  def tagging_acceptance_rate
    taggings = Tagging.where(suggester: self)
    return 0 if taggings.count == 0
    (taggings.where(status: :approved).count.to_f / taggings.count.to_f).round(2)*100
  end

  def pending_taggings
    Tagging.where(suggester: self, status: :pending)
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
      user.crowdsourcer = false if user.crowdsourcer.nil?
      user.save!
    end
  end
end
