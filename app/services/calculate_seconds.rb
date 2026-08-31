class CalculateSeconds
  attr_reader :time

  def initialize(time)
    @time = time
  end

  # "M:SS" or "H:MM:SS" -> total seconds. Nil-safe: returns nil for no time.
  def convert
    parts = @time.to_s.scan(/\d+/).map(&:to_i)
    return nil if parts.empty?
    parts.inject(0) { |acc, part| acc * 60 + part }
  end
end
