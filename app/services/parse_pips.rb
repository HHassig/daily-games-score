class ParsePips
  # 351 (edition, post-date) pairs from a share forum put #1 on 2025-08-18,
  # NYT's launch day for Pips.
  EPOCH = Date.new(2025, 8, 17)
  HEADER = /\APips\s+#([\d.,]+)\s+(Easy|Medium|Hard)\b/i
  TIME = /\d+(?::\d{2}){1,2}/

  attr_reader :result

  def initialize(result)
    @result = result
  end

  # One difficulty block: "Pips #379 Easy 🟢" newline "0:32 [🍪]".
  # GameChunks splits bundled multi-difficulty shares before this runs.
  def parse
    lines = @result.original.to_s.split("\n").map(&:strip).reject(&:empty?)
    match = lines.first.to_s.match(HEADER)
    time = lines[1..].to_a.filter_map { |l| l[TIME] }.first
    return @result if match.nil? || time.nil?
    @result.edition = match[1].gsub(/[.,]/, "")
    @result.numeric_score = time
    @result.timer = CalculateSeconds.new(time).convert
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParsePips failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end
end
