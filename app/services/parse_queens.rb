class ParseQueens
  include LinkedinTimedParse
  EPOCH = Date.new(2024, 4, 30)

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    @result.score = detail_lines.first # "First 👑s: 🟪 🟨 🟥"
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
