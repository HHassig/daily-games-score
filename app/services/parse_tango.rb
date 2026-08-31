class ParseTango
  include LinkedinTimedParse
  EPOCH = Date.new(2024, 10, 7)

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    @result.score = detail_lines # "First 5 placements:" + the grid rows
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end
end
