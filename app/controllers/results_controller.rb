class ResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def index
    @editions = Result.where(game: @game).distinct.pluck(:edition)
    @results = Result.where(game: @game, user: current_user).order(edition: :desc)
    @friends = 1
  end

  def show
    @result = Result.find(params[:id])
    @game = Game.find(@result.game_id)
    @friends = 1
  end

  def edit
  end

  def new
    @result = Result.new
  end

  def create
    @game = Game.find(params[:game_name])
    redirect_to game_result_path(@game.name, ParseResult.new(Result.new(result_params.merge(user_id: current_user.id, game_id: params[:game_name]))).parse)
  end

  private

  def set_game
    @game = Game.find_by(name: params[:game_name])
  end

  def result_params
    params.require(:result).permit(:score, :game_id, :date, :edition, :user_id, :numeric_score, :original)
  end
end
