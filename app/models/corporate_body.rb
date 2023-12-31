class CorporateBody < ApplicationRecord
  has_many :involvements, class_name: 'InvolvedAuthority', as: :authority, dependent: :destroy

end
