require "open-uri"

class ChatId
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def set
    JSON.parse(URI.open("#{ENV.fetch('TELEGRAM_API_KEY')}/getUpdates").read)["result"].each { |info| find_chat_id(info, @user) }
  end

  private

  def find_chat_id(info, user)
    username = info["message"]["from"]["username"]
    chat_id = info["message"]["from"]["id"] if user == User.find_by(telegram_username: username) unless username.nil?
    chat_id = info["message"]["from"]["id"] if user == User.find_by(email: info["message"]["text"])
    user.update!(telegram_chat_id: chat_id) unless chat_id.nil?
  end
end
