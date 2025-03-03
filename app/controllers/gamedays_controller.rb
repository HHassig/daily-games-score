class GamedaysController < ApplicationController
  before_action :authenticate_user!
  def index
    @gamedays = Gameday.all.order(date: :desc)
  end

  def show
    @gameday = Gameday.find_by(date: params[:date])
    @results = Result.where(user: current_user, gameday_id: @gameday.id)
    redirect_to games_path if @gameday.date == Date.today.strftime("%Y-%m-%d")
  end
end
