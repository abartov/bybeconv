class Realizer < ActiveRecord::Base
  belongs_to :expression
  belongs_to :person
  enum role: [:author, :editor, :illustrator, :translator]
end
