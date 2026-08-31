class LeaderboardsController < ApplicationController
  def index
    date = params[:date].presence || Date.today.strftime("%Y-%m-%d")
    @presenter = LeaderboardsPresenter.new(date)
    @gameday = @presenter.gameday
  end

  def show
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end
end
