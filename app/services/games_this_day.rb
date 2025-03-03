class GamesThisDay
  attr_reader :gameday, :user

  def initialize(gameday, user)
    @gameday = gameday
    @user = user
  end

  def games
    Result.where(user: @user, gameday_id: @gameday.id).map {|result| Game.find(result.game_id)}.sort_by(&:name)
  end

  private

  def calculate_numeric_score(score)
    score.last.chars.uniq.length <= 1 ? score.size.to_s : "X"
  end
end
