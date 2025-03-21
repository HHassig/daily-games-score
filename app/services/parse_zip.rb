class ParseZip
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[0].match(/#(\d+)/)[1]
    @result.score = temp[0].match(/\d+:\d+/)[0]
    @result.numeric_score = temp[0].split("|").last.strip
    @result.timer = CalculateSeconds.new(@result.numeric_score.split(" ").first).convert
    @result.secondary_timer =
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2025, 3, 17) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end

  private

  def calculate_numeric_score(score)
    score.last.chars.uniq.length <= 1 ? score.size.to_s : "8"
  end
end
