class GamesThisDay
  attr_reader :gameday, :user

  def initialize(gameday, user)
    @gameday = gameday
    @user = user
  end

  def games
    Result.includes(:game).where(user: @user, gameday_id: @gameday.id).map(&:game).sort_by(&:name)
  end
end
