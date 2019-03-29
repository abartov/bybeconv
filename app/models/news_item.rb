class NewsItem < ApplicationRecord
  enum itemtype: %i(publication facebook youtube blog announcement recommendation)

end
