class ParseConnections
  EPOCH = Date.new(2023, 6, 11)
  ROW = /\A[🟨🟩🟦🟪]{4}\z/

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    lines = @result.original.to_s.split("\n").map(&:strip).reject(&:empty?)
    edition = lines.filter_map { |l| l[/\APuzzle\s+#([\d.,]+)/, 1] }.first
    rows = lines.grep(ROW)
    return @result if edition.nil? || rows.empty?
    @result.edition = edition.gsub(/[.,]/, "")
    @result.score = rows
    @result.won = rows.last.chars.uniq.length == 1
    # Guess rows taken: 4 = perfect ... 7 = three mistakes; a loss (mixed final
    # row after four mistakes) scores 8 so it sorts last.
    @result.numeric_score = @result.won ? rows.size.to_s : "8"
    @result.timer = @result.numeric_score.to_i
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParseConnections failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end
end
