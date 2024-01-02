class CorporateBody < ApplicationRecord
  has_many :involved_authorities, class_name: 'InvolvedAuthority', as: :authority, dependent: :destroy

end
