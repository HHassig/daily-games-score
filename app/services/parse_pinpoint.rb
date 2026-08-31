class ParsePinpoint
  include LinkedinTimedParse
  EPOCH = Date.new(2024, 4, 30)
  GRID  = /\((\d)\/(\d)\)/ # mobile result grid: "🤔 📌 ⬜ ⬜ ⬜ (2/5)"

  attr_reader :result

  def initialize(result)
    @result = result
  end

  # Desktop: "Pinpoint #306 | 4 pogingen" - the header is the ONLY authoritative
  # guess count (newer shares truncate the body to just the final guess line).
  # Mobile win: no "|", exactly one grid line, N in (N/5) = the winning guess.
  # Fail (any platform): no "N guesses" header and no pinned grid - all 5 used.
  def parse
    @result.edition = parse_edition
    return @result if @result.edition.nil?
    @result.score = body_lines
    if header.include?("|")
      guesses = header.split("|").last.to_s[/\d+/]
      return @result if guesses.nil?
      @result.timer = guesses.to_i
      @result.numeric_score = guesses.to_i == 1 ? "1 guess" : "#{guesses} guesses"
    elsif (grid = body_lines.find { |l| l.include?("📌") && l.match?(GRID) })
      n = grid.match(GRID)[1].to_i
      @result.timer = n
      @result.numeric_score = n == 1 ? "1 guess" : "#{n} guesses"
    else
      # All 5 guesses without a 100% match - sorts worse than any win (1..5),
      # same convention as Wordle's X/6 -> 7.
      @result.timer = 6
      @result.numeric_score = "X/5"
    end
    @result.won = @result.timer <= 5
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end

  private

  # Pinpoint mobile shares have NO time line, so the module's detail_lines
  # (which skips line 2 on mobile) would skip the grid - take everything
  # after the header instead.
  def body_lines
    lines[1..].to_a.reject { |l| l.empty? || l.include?("lnkd.in") || l.start_with?("🏅", "#") }
  end
end
