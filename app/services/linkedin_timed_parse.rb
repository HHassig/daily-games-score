# Shared grammar for LinkedIn's timed dailies (Queens, Crossclimb, Tango, Zip,
# Wend, Patches, Mini Sudoku).
#
#   Desktop line 1:  "<Name> #N | M:SS <qualifiers> <emoji>"
#   Mobile line 1:   "<Name> #N"     (time moves to line 2: "M:SS <emoji>")
#
# Detail lines (fill order / first crowns / grid) follow, then an optional
# lnkd.in footer and optional streak/CEO brag lines. Shares arrive in several
# locales (English + Dutch measured in prod), so qualifiers are never parsed
# positionally and counters must be noun-anchored.
module LinkedinTimedParse
  TIME = /\d+(?::\d{2}){1,2}/

  private

  def lines
    @lines ||= @result.original.to_s.split("\n").map(&:strip)
  end

  def header = lines.first.to_s

  # Mobile shares have no "|" in the HEADER (a brag line elsewhere may contain one).
  def mobile? = !header.include?("|")

  def parse_edition
    header.match(/#([\d.,]+)/)&.[](1)&.gsub(/[.,]/, "")
  end

  def parse_time_string
    source = mobile? ? lines[1].to_s : header.split("|").last.to_s
    source[TIME]
  end

  # Informative lines between the header (+ mobile time line) and the footer,
  # with streak/badge brags and hashtags dropped. Works when the footer is absent.
  def detail_lines
    from = mobile? ? 2 : 1
    lines[from..].to_a
      .reject { |l| l.empty? || l.include?("lnkd.in") }
      .reject { |l| l.start_with?("🏅", "#") }
  end

  def assign_time_and_day(epoch)
    @result.edition = parse_edition
    time = parse_time_string
    return false if @result.edition.nil? || time.nil?
    @result.numeric_score = time
    @result.timer = CalculateSeconds.new(time).convert
    @result.gameday_id = Gameday.find_or_create_by!(date: (epoch + @result.edition).strftime("%Y-%m-%d")).id
    true
  end

  def log_parse_failure(error)
    Rails.logger.warn("#{self.class.name} failed: #{error.class}: #{error.message}") if defined?(Rails.logger)
  end
end
