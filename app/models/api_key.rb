class ApiKey < ActiveRecord::Base
  attr_accessible :description, :email, :key, :status
end
