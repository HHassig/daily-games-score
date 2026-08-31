class LeaderboardsController < ApplicationController
  def index
    @gameday = Gameday.for(params[:date])
    @presenter = LeaderboardsPresenter.new(@gameday)
  end
end
