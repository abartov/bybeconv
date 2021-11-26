module V1
  module Entities
    class Recommendation < Grape::Entity
      expose :body, as: :fulltext
      expose :user_id, as: :recommender_user_id
      expose :recommender_home_url do |recommendation|
        # TODO: implement when field will be added
      end
      expose :recommendation_date do |recommendation|
        recommendation.created_at.to_date
      end
    end
  end
end
