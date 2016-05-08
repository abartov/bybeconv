class HtmlDir < ActiveRecord::Base
  belongs_to :person
  attr_accessible :public_domain, :author
end
