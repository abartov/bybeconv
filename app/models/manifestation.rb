class Manifestation < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_many :taggings
  has_many :tags, through: :taggings do
    def approved
      where(status: 'approved')
    end
  end
  #has_and_belongs_to_many :tags, -> { where "status = 'approved'" }

  has_paper_trail
  has_many :external_links

  def long?
    return false # TODO: implement
  end
  def copyright?
    return expressions[0].copyrighted # TODO: implement more generically
  end
  def chapters?
    return false # TODO: implement
  end
end
