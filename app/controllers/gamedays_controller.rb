class GamedaysController < ApplicationController
  before_action :authenticate_user!

  def index
    @gamedays = Gameday.where(id: Result.where(user: current_user).select(:gameday_id)).order(date: :desc).limit(60)
  end

  def show
    @gameday = Gameday.find_by(date: params[:date])
    return redirect_to gamedays_path if @gameday.nil?
    redirect_to games_path if @gameday.date == Date.today.strftime("%Y-%m-%d")
    @results = Result.includes(:game).where(user: current_user, gameday_id: @gameday.id)
  end
end
