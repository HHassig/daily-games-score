require "open-uri"

# Pulls pending Telegram updates and records game shares from linked users.
#
# NOTE: getUpdates is deliberately called WITHOUT `offset` - passing an offset
# CONFIRMS (discards) older updates on Telegram's side, but ChatId reads this
# same buffer to link accounts, and app-level dedup makes replays harmless.
# Telegram retains ~24h / 100 updates, plenty at this scale.
class FetchResult
  def score
    names = Game.pluck(:display_name, :name).to_h { |display, name| [display.to_s.downcase, name] }
    updates.each do |update|
      message = update["message"] || update["edited_message"]
      text = message&.dig("text")
      chat_id = message&.dig("from", "id")
      next if text.blank? || chat_id.nil?
      user = User.find_by(telegram_chat_id: chat_id.to_s)
      next if user.nil?
      GameChunks.split(text, names).each do |game_name, chunk|
        game = Game.find_by(name: game_name)
        next if game.nil?
        begin
          ParseResult.new(Result.new(game_id: game.id, user_id: user.id, original: chunk)).parse
        rescue => e
          Rails.logger.warn("FetchResult: skipped a #{game_name} share: #{e.class}: #{e.message}")
        end
      end
    end
    true
  end

  private

  def updates
    response = JSON.parse(URI.open("#{ENV.fetch('TELEGRAM_API_KEY')}/getUpdates").read)
    result = response["result"] || []
    Rails.logger.warn("FetchResult: update buffer at Telegram's 100 cap - possible drops") if result.size >= 100
    result
  rescue OpenURI::HTTPError, JSON::ParserError, SocketError, SystemCallError => e
    Rails.logger.warn("FetchResult: getUpdates failed: #{e.class}: #{e.message}")
    []
  end
end
