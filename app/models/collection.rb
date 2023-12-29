class Collection < ApplicationRecord
  belongs_to :publication
  belongs_to :toc
end
