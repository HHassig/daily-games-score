class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    counts = Result.where(user: current_user).group(:game_id).count
    @games = Game.where(id: counts.keys).sort_by { |game| -counts[game.id] }
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end

  def show
    @game = Game.find_by(name: params[:name])
    @following = Friendship.where(follower_id: current_user.id) if current_user
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end
end
