class ApiKey < ApplicationRecord
  enum :status, {
    enabled: 1,
    disabled: 2
  }, prefix: true

  validates_presence_of :status, :key, :email
  validates_uniqueness_of :email

  before_validation do
    self.email = self.email.downcase.strip
  end
end
