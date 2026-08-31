class ParseWordle
  EPOCH = Date.new(2021, 6, 19)
  # "Wordle 1.899 4/6*" - editions localize the thousands separator (both
  # "1.899" and "1,899" measured in prod); the star marks hard mode.
  HEADER = %r{\AWordle\s+([\d.,]+)\s+([1-6X])/6(\*?)\z}

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    lines = @result.original.to_s.split("\n").map(&:strip).reject(&:empty?)
    match = lines.first.to_s.match(HEADER)
    return @result if match.nil? # not a share - chat noise like "Wordle is hard"
    @result.edition = match[1].gsub(/[.,]/, "")
    @result.numeric_score = "#{match[2]}/6#{match[3]}"
    @result.timer = match[2] == "X" ? 7 : match[2].to_i
    @result.won = match[2] != "X"
    @result.score = lines[1..]
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParseWordle failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end
end
