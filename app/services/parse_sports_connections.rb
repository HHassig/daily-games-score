class ParseSportsConnections
  EPOCH = Date.new(2024, 9, 23)

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    lines = @result.original.to_s.split("\n").map(&:strip).reject(&:empty?)
    edition = lines.filter_map { |l| l[/\APuzzle\s+#([\d.,]+)/, 1] }.first
    return @result if edition.nil?
    @result.edition = edition.gsub(/[.,]/, "")
    body = lines.drop_while { |l| !l.start_with?("Puzzle") }.drop(1).map { |l| l.gsub(" ", "") }
    time_lines, grid = body.partition { |l| l.match?(/\ATime:/i) }
    return @result if grid.empty?
    @result.secondary_timer = CalculateSeconds.new(time_lines.first&.sub(/\ATime:\s*/i, "")).convert if time_lines.any?
    @result.score = grid
    @result.numeric_score = grid.last.chars.uniq.length <= 1 ? grid.size.to_s : "9"
    @result.timer = @result.numeric_score.to_i
    @result.won = @result.timer < 8
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParseSportsConnections failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end
end
