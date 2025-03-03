class ParseScore
  attr_reader :score

  def initialize(score)
    @score = score
  end

  def parse
    if score&.match?(/\A\s*[{\[]/)
      JSON.parse(score)
    else
      [score]
    end
  end
end
