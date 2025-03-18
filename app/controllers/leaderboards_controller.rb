class LeaderboardsController < ApplicationController
  def index
    @leaderboards = LeaderboardsPresenter.new(params[:date].present? ? params[:date] : Date.today.strftime("%Y-%m-%d")).set
  end

  def show
  end
end
