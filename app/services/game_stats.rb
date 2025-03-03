class GameStats
  attr_reader :user, :game

  def initialize(user, game)
    @user = user
    @game = game
    @game_stats = GameStat.find_or_create_by!(game_id: @game.id, user_id: @user.id)
    @results = Result.where(game_id: @game.id, user_id: @user.id)
  end

  def calculate
    unless @results.empty?
      @game_stats.played = @results.size
      @game_stats.average = @results.sum(:timer).to_f / @results.size
      @game_stats.best = @results.order(timer: :asc).first.timer
      # @game_stats.win_percent =
      @game_stats if @game_stats.save!
    end
  end
end
