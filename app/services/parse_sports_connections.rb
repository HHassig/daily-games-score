class ParseSportsConnections
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    temp = @result.original.split("\n")
    @result.edition = temp[1].match(/#(\d+)/)[1]
    score = temp[2..].map { |str| str.gsub(" ", "") }
    @result.score = score
    @result.numeric_score = calculate_numeric_score(score)
    @result.timer = @result.numeric_score.to_i
    @result.won = @result.timer.to_i < 8
    @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2024, 9, 23) + @result.edition).strftime("%Y-%m-%d")).id
    @result
  end

  private

  def calculate_numeric_score(score)
    puts score.last
    score = score[1..] if score.first.include?("Time:")
    score.last.chars.uniq.length <= 1 ? score.size.to_s : "9"
    score.last
  end
end
