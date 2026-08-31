class ParseResult
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

  attr_reader :result

  def initialize(result)
    @result = result
    @game = Game.find(@result.game_id)
    @user = User.find(@result.user_id)
  end

  # Returns the persisted result, or nil when the text wasn't a parseable share
  # (or the day was already recorded).
  def parse
    parser = PARSERS[@game.name]
    return nil if parser.nil?
    @result = parser.new(@result).parse
    return nil if @result.nil? || @result.gameday_id.nil?
    if Result.where(gameday_id: @result.gameday_id, user_id: @user.id, game_id: @game.id).empty?
      begin
        @result.save!
      rescue ActiveRecord::NotNullViolation, ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        return nil
      end
      CalculateAverage.new(@user, @game).average
    end
    @result.persisted? ? @result : nil
  end
end
