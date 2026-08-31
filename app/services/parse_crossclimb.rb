class ParseCrossclimb
  include LinkedinTimedParse
  EPOCH = Date.new(2024, 4, 30)

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    # Keep only the fill-order line; streak/CEO brags are dropped by detail_lines
    @result.score = detail_lines.find { |l| l.match?(/\A(Fill order|Invulvolgorde):/i) } || detail_lines.first
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
