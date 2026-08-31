class ParseWend
  include LinkedinTimedParse
  EPOCH = Date.new(2026, 6, 8)

  BACKTRACKS      = /(\d+)\s+(?:backtracks?|terugzett\w*)/i
  ZERO_BACKTRACKS = /no\s+backtracks/i

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    line = detail_lines.first # "With no hints & no backtracks"
    @result.score = line
    @result.secondary_timer =
      if (count = line.to_s[BACKTRACKS, 1])
        count.to_i
      elsif line.to_s.match?(ZERO_BACKTRACKS)
        0
      end
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
