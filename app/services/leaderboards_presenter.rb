class LeaderboardsPresenter
  attr_reader :date, :gameday

  def initialize(date)
    @date = date
    @gameday = Gameday.find_or_create_by!(date: date)
  end

  # Every game with its ranked results for the day (best first).
  def boards
    @boards ||= Game.all.map do |game|
      { game: game,
        results: Result.includes(:user).where(gameday_id: @gameday.id, game: game).order(:timer).limit(10) }
    end
  end

  # Games somebody played that day, busiest first.
  def played
    boards.select { |b| b[:results].any? }.sort_by { |b| [-b[:results].size, b[:game].display_name] }
  end

  # Games nobody has recorded yet.
  def unplayed
    boards.select { |b| b[:results].empty? }.map { |b| b[:game] }
  end

  # [[user, wins], ...] sorted by wins desc — ties on a game credit everyone tied.
  def champions
    tally = Hash.new(0)
    played.each do |board|
      best = board[:results].first.timer
      next if best.nil?
      board[:results].take_while { |r| r.timer == best }.each { |r| tally[r.user] += 1 }
    end
    tally.sort_by { |_user, wins| -wins }
  end
end
