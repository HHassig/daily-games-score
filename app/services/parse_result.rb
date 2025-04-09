class ParseResult
  attr_reader :result

  def initialize(result)
    @result = result
    @game = Game.find(@result.game_id)
    @user = User.find(@result.user_id)
    @mobile = !@result.original.include?("|")
  end

  def parse
    @result = parse_result
    begin
      @result.save! if Result.where(gameday_id: @result.gameday_id, user_id: @user.id, game_id: @game.id).empty?
    rescue ActiveRecord::NotNullViolation => e
      return nil
    end
    # GameStats.new(@user, @game).calculate
    CalculateAverage.new(@user, @game).average
    @result
  end

  private

  def parse_result
    return ParseWordle.new(@result).parse if @game.name == "wordle"
    return ParseSportsConnections.new(@result).parse if @game.name == "sportsconnections"
    return ParseConnections.new(@result).parse if @game.name == "connections"
    return ParsePinpoint.new(@result).parse if @game.name == "pinpoint"
    return ParseStrands.new(@result).parse if @game.name == "strands"
    return ParseZip.new(@result).parse if @game.name == "zip"
    if @mobile
      return ParseTango.new(@result).mobile if @game.name == "tango"
      return ParseQueens.new(@result).mobile if @game.name == "queens"
      ParseCrossclimb.new(@result).mobile if @game.name == "crossclimb"
    else
      return ParseTango.new(@result).parse if @game.name == "tango"
      return ParseQueens.new(@result).parse if @game.name == "queens"
      ParseCrossclimb.new(@result).parse if @game.name == "crossclimb"
    end
  end
end
