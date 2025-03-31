class LeaderboardsPresenter
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def set
    Game.all.map { |game| { game: game, results: Result.where(gameday_id: Gameday.find_or_create_by!(date: @date).id, game: game).order(:timer).limit(5) } }
  end
end
