class Expression < ActiveRecord::Base
  before_save :set_translation

  has_and_belongs_to_many :works
  has_and_belongs_to_many :manifestations
  has_and_belongs_to_many :people
  has_many :realizers
  has_many :persons, through: :realizers, class_name: 'Person'

  def determine_is_translation?
    # determine whether this expression is a translation or not, i.e. is in a different language to the work it expresses
    return nil if works.empty?
    language != works[0].orig_lang # TODO: handle multiple works?
  end

  def translators
    return persons.where(role: :translator)
  end
  protected
  def set_translation
    b = determine_is_translation?
    self.translation = determine_is_translation? unless b.nil?
    return true
  end
end
