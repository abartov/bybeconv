class WelcomeController < ApplicationController
  def index
    @open_proofs = Proof.where(status: 'new').count.to_s
    @open_recommendations = Recommendation.where(status: 'new').count.to_s
  end
end
