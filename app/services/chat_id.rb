# Links a user's account to their Telegram chat, using the contacts the poller
# has already seen. Returns true when the account ends up linked.
class ChatId
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def set
    return true if @user.telegram_chat_id.present?
    contact = TelegramContact.for_user(@user)
    return false if contact.nil?
    @user.update!(telegram_chat_id: contact.chat_id)
    true
  end
end
