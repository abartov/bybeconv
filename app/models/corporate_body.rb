class CorporateBody < ApplicationRecord
  has_many :involved_authorities, class_name: 'InvolvedAuthority', as: :authority, dependent: :destroy
  has_attached_file :profile_image, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, default_url: :placeholder_image_url, storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'

end
