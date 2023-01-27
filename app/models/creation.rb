class Creation < ApplicationRecord
  belongs_to :work, class_name: 'Work', foreign_key: 'work_id'
  belongs_to :person, class_name: 'Person', foreign_key: 'person_id'
  enum role: {
    author: 0,
    illustrator: 2
  }
end
