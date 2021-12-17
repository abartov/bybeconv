class Realizer < ApplicationRecord
  belongs_to :expression
  belongs_to :person
  enum role: {
    author: 0,
    editor: 1,
    illustrator: 2,
    translator: 3,
    adapter: 4
  }
end
