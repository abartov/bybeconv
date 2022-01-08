class Realizer < ApplicationRecord
  belongs_to :expression
  belongs_to :person
  enum role: {
    editor: 1,
    illustrator: 2,
    translator: 3
  }
end
