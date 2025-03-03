require "open-uri"

class FetchResult
  def score
    JSON.parse(URI.open("#{ENV.fetch('TELEGRAM_API_KEY')}/getUpdates").read)["result"].each { |message| assign_result(message) }
  end

  private

  def assign_result(message)
    user = User.find_by(telegram_chat_id: message["message"]["from"]["id"].to_s)
    unless user.nil?
      game = find_game(message["message"]["text"])
      ParseResult.new(Result.new(game_id: game.id, user_id: user.id, original: message["message"]["text"])).parse unless game.nil?
    end
  end

  def find_game(message)
    temp = message.split("\n").first
    Game.find_by("lower(display_name) = ?", temp.split(" ").first.include?(":") ? temp.downcase : temp.split(" ").first.downcase)
  end
end
