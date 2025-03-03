class ParseConnections
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[1].match(/#(\d+)/)[1]
    @result.score = temp[2..]
    @result.numeric_score = calculate_numeric_score(temp[2..])
    @result.timer = @result.numeric_score.to_i
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2023, 6, 11) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end

  private

  def calculate_numeric_score(score)
    score.last.chars.uniq.length <= 1 ? score.size.to_s : "8"
  end
end
