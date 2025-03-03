class CalculateSeconds
  attr_reader :time

  def initialize(time)
    @time = time
  end

  def convert
    minutes, seconds = @time.split(":").map(&:to_i)
    (minutes * 60) + seconds
  end
end
