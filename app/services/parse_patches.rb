class ParsePatches
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def parse
    begin
      temp = @result.original.split("\n")
      @result.edition = temp[0].match(/#(\d+)/)[1]
      @result.score = temp[1]
      @result.numeric_score = temp[0].split("|").last.strip
      @result.timer = CalculateSeconds.new(@result.numeric_score.split(" ").first).convert
      @result.secondary_timer = temp[1][/(\d+)\s+redraws?/, 1].to_i
      @result.gameday_id = Gameday.find_or_create_by!(date: (Date.new(2026, 3, 17) + @result.edition).strftime("%Y-%m-%d")).id
    rescue
      # Do nothing, just return @result as-is
    end
    @result
  end
end
