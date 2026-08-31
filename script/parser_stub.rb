# Standalone stand-ins for the Rails pieces the parsers touch, mimicking
# ActiveRecord type casting (string columns cast via to_s on assignment -
# Array#to_s == inspect, which is why ParseScore can JSON.parse stored grids;
# integer columns cast to_i). Lets script/parser_test.rb run the real parsers
# in app/services/ without Rails or a database.
#
# NOT loaded by the Rails app or `bin/rails test` - `ruby script/parser_test.rb`.
require "date"
require "json"

class Result
  attr_reader :original, :edition, :score, :numeric_score, :timer, :secondary_timer
  attr_accessor :gameday_id, :game_id, :user_id, :won

  def initialize(original)
    @original = original
  end

  def score=(value)
    @score = value.nil? ? nil : value.to_s
  end

  def numeric_score=(value)
    @numeric_score = value.nil? ? nil : value.to_s
  end

  def edition=(value)
    @edition = value.nil? ? nil : value.to_i
  end

  def timer=(value)
    @timer = value.nil? ? nil : value.to_i
  end

  def secondary_timer=(value)
    @secondary_timer = value.nil? ? nil : value.to_i
  end
end

FakeGameday = Struct.new(:date, :id)

class Gameday
  def self.find_or_create_by!(date:)
    FakeGameday.new(date, date)
  end
end

APP = File.expand_path("../app/services", __dir__)
require "#{APP}/calculate_seconds"
require "#{APP}/linkedin_timed_parse"
Dir["#{APP}/parse_*.rb"].sort.each do |file|
  require file unless file.end_with?("parse_result.rb", "parse_score.rb")
end
require "#{APP}/game_chunks"

PARSERS = {
  "wordle"            => ParseWordle,
  "connections"       => ParseConnections,
  "sportsconnections" => ParseSportsConnections,
  "strands"           => ParseStrands,
  "pinpoint"          => ParsePinpoint,
  "zip"               => ParseZip,
  "wend"              => ParseWend,
  "patches"           => ParsePatches,
  "tango"             => ParseTango,
  "queens"            => ParseQueens,
  "crossclimb"        => ParseCrossclimb,
  "minisudoku"        => ParseMiniSudoku,
  "minicrossword"     => ParseMiniCrossword,
  "pips-easy"         => ParsePips,
  "pips-medium"       => ParsePips,
  "pips-hard"         => ParsePips,
}.freeze

def replay(game, original)
  result = Result.new(original)
  PARSERS.fetch(game).new(result).parse
  { edition: result.edition, numeric_score: result.numeric_score, timer: result.timer,
    secondary_timer: result.secondary_timer, gameday: result.gameday_id, score: result.score,
    won: result.won }
end
