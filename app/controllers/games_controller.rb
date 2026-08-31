class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    counts = Result.where(user: current_user).group(:game_id).count
    @games = Game.where(id: counts.keys).sort_by { |game| -counts[game.id] }
    @gameday = Gameday.for(params[:date])
  end

  def show
    @game = Game.find_by!(name: params[:name])
    @gameday = Gameday.for(params[:date])
  end
end
