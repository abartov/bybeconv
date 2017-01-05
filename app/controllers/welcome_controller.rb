include BybeUtils
class WelcomeController < ApplicationController
  def index
    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    if current_user && current_user.editor?
      @open_proofs = Proof.where(status: 'new').count.to_s
      @open_recommendations = Recommendation.where(status: 'new').count.to_s
    end
  end
end
