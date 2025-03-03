class ParseTango
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[0].split("#")[1].split("|")[0].strip
    @result.score = temp[1..temp.size-2]
    @result.numeric_score = temp[0].split("|").last.strip
    @result.timer = CalculateSeconds.new(@result.numeric_score.split(" ").first).convert
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2024, 10, 7) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end

  def mobile
    temp = @result.original.split("\n")
    @result.edition = temp[0].split("#")[1].split("|")[0].strip
    @result.score = temp[1..temp.size-2]
    @result.numeric_score = JSON.parse(@result.score).first.split(" ").first
    @result.timer = CalculateSeconds.new(@result.numeric_score.split(" ").first).convert
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2024, 10, 7) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end
end
