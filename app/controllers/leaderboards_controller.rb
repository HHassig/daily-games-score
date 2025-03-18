class LeaderboardsController < ApplicationController
  def index
    @leaderboards = LeaderboardsPresenter.new(params[:date].present? ? params[:date] : Date.today.strftime("%Y-%m-%d")).set
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end

  def show
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end
end
