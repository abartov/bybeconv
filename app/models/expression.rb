class Expression < ActiveRecord::Base
  before_save :set_translation

  has_and_belongs_to_many :works
  has_and_belongs_to_many :manifestations
  has_and_belongs_to_many :people

  def determine_is_translation?
    # determine whether this expression is a translation or not, i.e. is in a different language to the work it expresses
    language != works[0].orig_lang # TODO: handle multiple works?
  end

  protected
  def set_translation
    self.translation = determine_is_translation?
    return true
  end
end
