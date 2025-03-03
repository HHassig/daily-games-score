class ParseWordle
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split(" ")
    @result.edition = temp[1].gsub(",", "").gsub(".", "").to_i
    @result.numeric_score = temp[2]
    @result.timer = int_score(@result.numeric_score[0])
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2021, 6, 19) + @result.edition).strftime("%Y-%m-%d")).id
    @result.score = temp[3..]
    @result
  end

  private

  def int_score(score)
    score == "X" ? 7 : score.to_i
  end
end
