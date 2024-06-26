class Tag < ApplicationRecord

  has_many :taggings, dependent: :destroy
  has_many :tag_names, dependent: :destroy
  # NOTE: the 'name' field in tag is the *preferred*/display name. All tag names are in TagName records (including this main preferred one, so that one can search *only* the TagName records)
  after_create :create_tag_name

  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  belongs_to :approver, foreign_key: :approver_id, class_name: 'User', optional: true
  enum status: [:pending, :approved, :rejected, :escalated]
  validates :name, presence: true
  validates :created_by, presence: true
  validates :status, presence: true
  
  scope :pending, -> { where(status: Tag.statuses[:pending]) }
  scope :approved, -> { where(status: Tag.statuses[:approved]) }
  scope :rejected, -> { where(status: Tag.statuses[:rejected]) }
  scope :by_popularity, -> { order('taggings_count DESC') }

  scope :by_user, ->(user) { where(created_by: user.id) }
  scope :by_name, ->(name) { joins(:tag_names).where(tag_names: {name: name}) } # only use this to search for tags, to ensure aliases are searched as well!

  def approve!(approver)
    self.approver = approver
    self.status = Tag.statuses[:approved]
    self.save
  end
  def reject!(rejecter)
    self.update(status: Tag.statuses[:rejected], approver_id: rejecter.id)
    self.taggings.update_all(status: Tagging.statuses[:rejected], approved_by: rejecter.id)
  end
  def escalate!(escalator)
    self.update(status: Tag.statuses[:escalated], approver_id: escalator.id)
  end
  def unreject!
    self.update(status: Tag.statuses[:pending])
  end
  def unapprove!
    self.update(status: Tag.statuses[:pending])
  end
  def delete_taggings
    self.taggings.destroy_all
  end
  def delete_taggings_by_user(user)
    self.taggings.where(created_by: user.id).destroy_all
  end
  def approved_taggings
    self.taggings.where(status: Tagging.statuses[:approved])
  end
  def work_taggings
    self.taggings.where(taggable_type: 'Work')
  end
  def expression_taggings
    self.taggings.where(taggable_type: 'Expression')
  end
  def manifestation_taggings
    self.taggings.where(taggable_type: 'Manifestation')
  end
  def anthology_taggings
    self.taggings.where(taggable_type: 'Anthology')
  end

  def authority_taggings
    taggings.where(taggable_type: 'Authority')
  end

  def merge_into(tag)
    self.tag_names.update_all(tag_id: tag.id) # make all this tag's tag_names be aliases of the destination tag
    self.merge_taggings_into(tag)
    self.reload # to avoid destroying the taggings we just moved!
    self.destroy
  end

  def merge_taggings_into(tag)
    self.taggings.each do |tagging|
      # avoid duplicating taggings post-merge
      if tag.taggings.where(taggable_id: tagging.taggable_id, taggable_type: tagging.taggable_type).exists?
        tagging.destroy
      else
        tagging.update!(tag_id: tag.id)
      end
    end
  end
  def prev_tags_alphabetically(limit = 3)
    TagName.where('name < ?', self.name).order('name DESC').limit(limit)
  end
  def next_tags_alphabetically(limit = 3)
    TagName.where('name > ?', self.name).order('name ASC').limit(limit)
  end
  def self.cached_popular_tags
    Rails.cache.fetch('popular_tags', expires_in: 1.hour) do
      Tag.approved.by_popularity.limit(10)
    end
  end

  protected
  def create_tag_name # create a TagName with the preferred name
    TagName.create!(tag_id: self.id, name: self.name)
  end
end
