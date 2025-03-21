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
    @result.secondary_timer = temp[1].scan(/\d+/).first.to_i
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2025, 3, 17) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end
end
