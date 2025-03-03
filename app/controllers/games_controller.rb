class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @games = Result.where(user: current_user).map(&:game).uniq.sort_by { |game| -Result.where(user: current_user).count { |r| r.game == game } }
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end

  def show
    @game = Game.find_by(name: params[:name])
    @following = Friendship.where(follower_id: current_user.id) if current_user
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end
end
