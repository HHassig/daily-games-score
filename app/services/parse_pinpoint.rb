class ParsePinpoint
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[0].match(/#(\d+)/)[1]
    @result.score = temp[1..temp.size - 2]
    @result.numeric_score = temp[0].split("|").last.strip
    @result.timer = @result.numeric_score.split(" ").first.to_i
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2024, 4, 30) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end
end
