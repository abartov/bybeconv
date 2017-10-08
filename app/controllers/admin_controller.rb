class AdminController < ApplicationController
  before_filter :require_editor
  before_filter :require_admin, only: [:missing_languages]

  def index
    if current_user && current_user.editor?
      @open_proofs = Proof.where(status: 'new').count.to_s
      @open_recommendations = Recommendation.where(status: 'new').count.to_s
    end
  end

  def missing_languages
    ex = Expression.joins([:realizers, :works]).where(realizers: {role: Realizer.roles[:translator]}, works: {orig_lang: 'he'})
    @mans = ex.map{|e| e.manifestations[0]}
  end
end