class Toc < ActiveRecord::Base
  attr_accessible :person_id, :status, :toc
  has_paper_trail
end
