class Realizer < ApplicationRecord
  belongs_to :expression
  belongs_to :person
  enum role: [:author, :editor, :illustrator, :translator, :adapter]
end
