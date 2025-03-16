class CalculateAverage
  attr_reader :user, :game

  def initialize(user, game)
    @user = user
    @game = game
  end

  def average
    result_stats = Result.where(game: @game, user: @user).pick("SUM(timer) AS total_time, COUNT(*) AS result_count")
    return Average.find_or_create_by!(user: @user, game: @game, score: 0.0) if result_stats.nil? || result_stats[1] == 0
    total_time, result_count = result_stats
    new_score = total_time.to_f / result_count
    average = Average.find_or_create_by!(user: @user, game: @game)
    average.update!(score: new_score) if average.score != new_score
    average
  end
end
