module CompactedImpressions
  extend ActiveSupport::Concern
  included do
    has_many(:year_totals, as: :item, :dependent => :delete_all)
  end
end