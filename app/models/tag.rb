class Tag < ApplicationRecord
  
  has_many :taggings, dependent: :destroy
  has_many :tag_names, dependent: :destroy
  # NOTE: the 'name' field in tag is the *preferred*/display name. All tag names are in TagName records (including this main preferred one, so that one can search *only* the TagName records)
  after_create :create_tag_name

  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  belongs_to :approver, foreign_key: :approver_id, class_name: 'User', optional: true
  enum status: [:pending, :approved, :rejected]
  validates :name, presence: true
  validates :created_by, presence: true
  validates :status, presence: true
  
  scope :pending, -> { where(status: Tag.statuses[:pending]) }
  scope :approved, -> { where(status: Tag.statuses[:approved]) }
  scope :rejected, -> { where(status: Tag.statuses[:rejected]) }

  scope :by_user, ->(user) { where(created_by: user.id) }

  def approve!
    self.update(status: Tag.statuses[:approved])
  end
  def reject!
    self.update(status: Tag.statuses[:rejected])
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
  def people_taggings
    self.taggings.where(taggable_type: 'Person')
  end
  protected
  def create_tag_name # create a TagName with the preferred name
    TagName.create!(tag_id: self.id, name: self.name)
  end
end
