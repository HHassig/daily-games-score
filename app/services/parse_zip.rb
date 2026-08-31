class ParseZip
  include LinkedinTimedParse
  EPOCH = Date.new(2025, 3, 17)

  BACKTRACKS      = /(\d+)\s+(?:backtracks?|nieuwe\s+poging(?:en)?)/i
  ZERO_BACKTRACKS = /no\s+backtracks|zonder(?:\s+hints\s+en)?\s+nieuwe\s+pogingen|and\s+flawless|en\s+foutloos/i
  HINTS_ONLY      = /\A(?:with\s+no\s+hints|zonder\s+hints)\s*\W*\z/i

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    return @result unless assign_time_and_day(EPOCH)
    line = detail_lines.first
    @result.score = line
    @result.secondary_timer = backtracks(line)
    @result
  rescue => e
    log_parse_failure(e)
    @result
  end

  private

  # Noun-anchored, bilingual, with explicit unknown semantics: a celebrity or
  # streak line carries digits that are NOT backtracks — store nil, never
  # fabricate 0 (and never let a hint count through).
  def backtracks(line)
    return nil if line.nil?
    if (count = line[BACKTRACKS, 1])
      count.to_i
    elsif line.match?(ZERO_BACKTRACKS) || line.match?(HINTS_ONLY)
      0
    end
  end
end
