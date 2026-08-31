class ParseStrands
  EPOCH = Date.new(2024, 3, 3)

  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    lines = @result.original.to_s.split("\n").map(&:strip)
    edition = lines.first.to_s[/\AStrands\s+#([\d.,]+)/, 1]
    return @result if edition.nil? || lines.size < 2
    @result.edition = edition.gsub(/[.,]/, "")
    @result.score = lines[1..].map { |l| l.gsub(/[“”]/, "") }.reject(&:empty?)
    hints = @result.original.count("💡")
    @result.numeric_score = hints.to_s
    @result.timer = hints
    @result.won = true # Strands cannot be failed
    @result.gameday_id = Gameday.find_or_create_by!(date: (EPOCH + @result.edition).strftime("%Y-%m-%d")).id
    @result
  rescue => e
    Rails.logger.warn("ParseStrands failed: #{e.class}: #{e.message}") if defined?(Rails.logger)
    @result
  end
end
