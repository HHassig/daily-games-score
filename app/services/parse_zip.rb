class ParseZip
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[0].match(/#(\d+)/)[1]
    @result.score = temp[1..].map { |t| t.gsub(/[“”]/, "") }
    @result.numeric_score = @result.score.count("💡")
    @result.timer = @result.numeric_score
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2024, 3, 3) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end

  private

  def calculate_numeric_score(score)
    score.last.chars.uniq.length <= 1 ? score.size.to_s : "8"
  end
end
