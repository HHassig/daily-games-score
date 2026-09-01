class TelegramContact < ApplicationRecord
  def self.record(message)
    from = message["from"] || {}
    return if from["id"].blank?
    contact = find_or_initialize_by(chat_id: from["id"].to_s)
    contact.username = from["username"] if from["username"].present?
    contact.last_message = message["text"] if message["text"].present?
    contact.save!
    contact
  end

  # The contact that matches a user: their Telegram username, or a message
  # whose entire text is their account email.
  def self.for_user(user)
    by_username = where("lower(username) = ?", user.telegram_username.to_s.downcase).first if user.telegram_username.present?
    by_username || where("lower(trim(last_message)) = ?", user.email.to_s.downcase).first
  end
end
