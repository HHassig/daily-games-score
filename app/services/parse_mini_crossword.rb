class ParseMiniCrossword
  # The Mini's share carries the puzzle DATE, not an edition number; the badge
  # URL params are authoritative when present. Edition = days since the Mini's
  # 2014-08-21 debut, so it stays a stable per-day integer.
  FIRST_MINI = Date.new(2014, 8, 21)
  BADGE_DATE = /badges\/games\/mini\.\w+\?[^\s"]*\bd=(\d{4}-\d{2}-\d{2})/
  BADGE_TIME = /badges\/games\/mini\.\w+\?[^\s"]*\bt=(\d+)/
  SENTENCE = %r{(\d{1,2})/(\d{1,2})/(\d{4})\s+New York Times Mini Crossword\s+in\s+(\d+):(\d{2})}

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    text = @result.original.to_s
    date, seconds = extract(text)
    return @result if date.nil? || seconds.nil? || date > Date.today
    @result.edition = (date - FIRST_MINI).to_i
    @result.timer = seconds
    @result.numeric_score = format("%d:%02d", seconds / 60, seconds % 60)
    @result.won = true
    @result.gameday_id = Gameday.find_or_create_by!(date: date.strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParseMiniCrossword failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end

  private

  def extract(text)
    if (d = text[BADGE_DATE, 1]) && (t = text[BADGE_TIME, 1])
      [Date.iso8601(d), t.to_i]
    elsif (m = text.match(SENTENCE))
      [Date.new(m[3].to_i, m[1].to_i, m[2].to_i), m[4].to_i * 60 + m[5].to_i]
    else
      [nil, nil]
    end
  end
end
