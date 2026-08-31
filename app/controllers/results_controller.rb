class ResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def index
    @results = Result.where(game: @game, user: current_user).order(edition: :desc)
  end

  def show
    @result = Result.find(params[:id])
    @game = @result.game
  end

  def new
    @result = Result.new
  end

  def create
    result = ParseResult.new(Result.new(result_params.merge(user_id: current_user.id, game_id: @game.id))).parse
    if result&.persisted?
      redirect_to game_result_path(@game.name, result)
    elsif (existing = existing_result(result))
      redirect_to game_result_path(@game.name, existing), notice: "That day was already recorded."
    else
      redirect_to new_game_result_path(@game.name), alert: "Couldn't read that score — paste the exact share text."
    end
  end

  private

  def set_game
    @game = Game.find_by!(name: params[:game_name])
  end

  def existing_result(parsed)
    return nil if parsed&.gameday_id.nil?
    Result.find_by(user: current_user, game: @game, gameday_id: parsed.gameday_id)
  end

  def result_params
    params.require(:result).permit(:original)
  end
end
