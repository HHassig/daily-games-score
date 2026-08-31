class ParseMiniSudoku
  include LinkedinTimedParse
  # "Mini Sudoku #385 | 0:36 with no hints ✏️" sent 2026-08-31 -> #1 was
  # 2026 - 385 days = 2025-08-12, LinkedIn's announced launch day.
  EPOCH = Date.new(2025, 8, 11)

  HINTS      = /(\d+)\s+(?:hints?|hulplijn\w*)/i
  ZERO_HINTS = /no\s+hints|zonder\s+hulplijnen|zonder\s+hints/i

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    # The share's only detail line is a marketing tagline - no score content.
    qualifier = header.split("|").last.to_s
    @result.secondary_timer =
      if (count = qualifier[HINTS, 1])
        count.to_i
      elsif qualifier.match?(ZERO_HINTS)
        0
      end
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
