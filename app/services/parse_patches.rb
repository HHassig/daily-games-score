class ParsePatches
  include LinkedinTimedParse
  EPOCH = Date.new(2026, 3, 17)

  REDRAWS      = /(\d+)\s+redraws?/i
  ZERO_REDRAWS = /no\s+redraws/i

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    line = detail_lines.first # "With no hints & no redraws"
    @result.score = line
    @result.secondary_timer =
      if (count = line.to_s[REDRAWS, 1])
        count.to_i
      elsif line.to_s.match?(ZERO_REDRAWS)
        0
      end
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
