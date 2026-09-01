class LeaderboardsPresenter
  PIPS_ORDER = %w[pips-easy pips-medium pips-hard].freeze

  attr_reader :gameday

  def initialize(gameday)
    @gameday = gameday
  end

  # Every game with its ranked results for the day (best first).
  def boards
    @boards ||= Game.all.map do |game|
      { game: game,
        results: Result.includes(:user).where(gameday_id: @gameday.id, game: game).order(:timer).limit(10) }
    end
  end

  # Games somebody played that day (Pips excluded - see #pips), busiest first.
  def played
    boards.select { |b| b[:results].any? && !pips?(b[:game]) }
          .sort_by { |b| [-b[:results].size, b[:game].display_name] }
  end

  # Games nobody has recorded yet; the three Pips difficulties collapse to one.
  def unplayed
    singles = boards.select { |b| b[:results].empty? && !pips?(b[:game]) }.map { |b| b[:game] }
    singles += [pips_boards.first[:game]] if pips_boards.any? && pips.nil?
    singles
  end

  # The combined Pips card: Easy/Medium/Hard boards in difficulty order, or
  # nil when nobody played any difficulty that day.
  def pips
    return nil if pips_boards.all? { |b| b[:results].empty? }
    pips_boards
  end

  # [[user, wins], ...] sorted by wins desc - ties on a game credit everyone tied.
  def champions
    tally = Hash.new(0)
    boards.select { |b| b[:results].any? }.each do |board|
      best = board[:results].first.timer
      next if best.nil?
      board[:results].take_while { |r| r.timer == best }.each { |r| tally[r.user] += 1 }
    end
    tally.sort_by { |_user, wins| -wins }
  end

  private

  def pips?(game)
    game.pips?
  end

  def pips_boards
    @pips_boards ||= boards.select { |b| pips?(b[:game]) }
                           .sort_by { |b| PIPS_ORDER.index(b[:game].name) || 99 }
  end
end
