class RecommendationsController < ApplicationController
  def show
  end

  def display
    @r = Recommendation.find(params[:id])
    render partial: 'display'
  end

  def edit
  end

  def update
  end

  def create
    if current_user
      @r = Recommendation.new(body: sanitize(params[:recommendation][:body]), user: current_user, status: Recommendation.statuses[:pending], manifestation_id: params[:manifestation_id])
      @r.save!
    else
      flash[:error] = t(:forbidden)
      redirect_to '/'
    end
  end

  def destroy
    @id = params[:id]
    @r = Recommendation.find(@id)
    if current_user.id == @r.user_id # disallow deleting other people's stuff
      @r.destroy!
    else
      flash[:error] = t(:forbidden)
      redirect_to '/'
    end
  end
end
