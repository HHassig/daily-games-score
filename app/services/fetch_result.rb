require "open-uri"

# Polls the Telegram bot for new messages and records any game shares.
#
# Runs unattended every 5 minutes (see config/recurring.yml) and on demand
# from the ↻ Refresh scores button, so scores appear on the public leaderboard
# without anyone being signed in.
#
# Updates are ACKNOWLEDGED via the stored offset: Telegram otherwise keeps
# re-delivering the same 24h buffer and caps a single response at 100 updates,
# which would silently drop the newest scores on a busy day. Every message is
# mirrored into telegram_contacts first, so acknowledging one never costs us
# the ability to link an account later.
class FetchResult
  LIMIT = 100

  def score
    updates = fetch
    return true if updates.empty?
    names = Game.pluck(:display_name, :name).to_h { |display, name| [display.to_s.downcase, name] }
    updates.each do |update|
      message = update["message"] || update["edited_message"]
      next if message.nil?
      begin
        TelegramContact.record(message)
        user = resolve_user(message)
        next if user.nil? || message["text"].blank?
        record_scores(user, message["text"], names)
      rescue => e
        Rails.logger.warn("FetchResult: skipped update #{update['update_id']}: #{e.class}: #{e.message}")
      end
    end
    TelegramState.current.update!(last_update_id: updates.filter_map { |u| u["update_id"] }.max)
    true
  end

  private

  def fetch
    state = TelegramState.current
    params = { limit: LIMIT, timeout: 0 }
    params[:offset] = state.last_update_id + 1 if state.last_update_id
    url = "#{ENV.fetch('TELEGRAM_API_KEY')}/getUpdates?#{params.to_query}"
    result = JSON.parse(URI.open(url, read_timeout: 20).read)["result"] || []
    Rails.logger.info("FetchResult: #{result.size} update(s)") if result.any?
    result
  rescue OpenURI::HTTPError, JSON::ParserError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.warn("FetchResult: getUpdates failed: #{e.class}: #{e.message}")
    []
  end

  # Known sender, or a first-time sender we can match to an account by their
  # Telegram username or by the account email they sent.
  def resolve_user(message)
    from = message["from"] || {}
    chat_id = from["id"]
    return nil if chat_id.blank?
    user = User.find_by(telegram_chat_id: chat_id.to_s)
    return user if user

    user = User.where("lower(telegram_username) = ?", from["username"].to_s.downcase).first if from["username"].present?
    user ||= User.where("lower(email) = ?", message["text"].to_s.strip.downcase).first if message["text"].present?
    user&.update!(telegram_chat_id: chat_id.to_s)
    user
  end

  def record_scores(user, text, names)
    GameChunks.split(text, names).each do |game_name, chunk|
      game = Game.find_by(name: game_name)
      next if game.nil?
      ParseResult.new(Result.new(game_id: game.id, user_id: user.id, original: chunk)).parse
    end
  end
end
