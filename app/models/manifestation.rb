class Manifestation < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_paper_trail

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
