# frozen_string_literal: true

# Represents data specific for authors presented not by single person but by organization
class CorporateBody < ApplicationRecord
  has_one :authority, inverse_of: :corporate_body, dependent: :destroy
end
