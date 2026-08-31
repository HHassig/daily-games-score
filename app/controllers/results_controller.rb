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
    original = result_params[:original]
    names = Game.pluck(:display_name, :name).to_h { |display, name| [display.to_s.downcase, name] }
    chunks = GameChunks.split(original, names)
    chunks = [[@game.name, original]] if chunks.empty? # unclassifiable: trust the page's game
    results = chunks.filter_map do |game_name, chunk|
      game = Game.find_by(name: game_name)
      next if game.nil?
      ParseResult.new(Result.new(original: chunk, user_id: current_user.id, game_id: game.id)).parse
    end
    if results.size > 1
      redirect_to games_path, notice: "Recorded #{results.size} scores."
    elsif results.one?
      redirect_to game_result_path(results.first.game.name, results.first)
    elsif (existing = existing_result_for(chunks))
      redirect_to game_result_path(existing.game.name, existing), notice: "That day was already recorded."
    else
      redirect_to new_game_result_path(@game.name), alert: "Couldn't read that score — paste the exact share text."
    end
  end

  private

  def set_game
    @game = Game.find_by!(name: params[:game_name])
  end

  def existing_result_for(chunks)
    chunks.each do |game_name, chunk|
      game = Game.find_by(name: game_name)
      next if game.nil?
      probe = Result.new(original: chunk, user_id: current_user.id, game_id: game.id)
      ParseResult::PARSERS[game.name]&.new(probe)&.parse
      next if probe.gameday_id.nil?
      existing = Result.find_by(user: current_user, game: game, gameday_id: probe.gameday_id)
      return existing if existing
    end
    nil
  end

  def result_params
    params.require(:result).permit(:original)
  end
end
