class CalculateAverage
  attr_reader :user, :game

  def initialize(user, game)
    @user = user
    @game = game
  end

  def average
    total, count = Result.where(game: @game, user: @user)
                         .pick(Arel.sql("SUM(timer), COUNT(timer)"))
    new_score = count.to_i.positive? ? total.to_f / count : 0.0
    record = Average.find_or_create_by!(user: @user, game: @game)
    record.update!(score: new_score) if record.score != new_score
    record
  end
end
