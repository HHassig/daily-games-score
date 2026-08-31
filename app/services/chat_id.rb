require "open-uri"

# Links a user to their Telegram chat id: the user either has their telegram
# username on file, or sends their account email to the bot.
class ChatId
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def set
    updates.each { |update| find_chat_id(update) }
  end

  private

  def updates
    JSON.parse(URI.open("#{ENV.fetch('TELEGRAM_API_KEY')}/getUpdates").read)["result"] || []
  rescue OpenURI::HTTPError, JSON::ParserError, SocketError, SystemCallError => e
    Rails.logger.warn("ChatId: getUpdates failed: #{e.class}: #{e.message}")
    []
  end

  def find_chat_id(update)
    message = update["message"] || update["edited_message"]
    return if message.nil?
    from = message["from"] || {}
    matched = (from["username"].present? && from["username"] == @user.telegram_username) ||
              (message["text"].present? && message["text"].strip.casecmp?(@user.email))
    @user.update!(telegram_chat_id: from["id"].to_s) if matched && from["id"]
  end
end
