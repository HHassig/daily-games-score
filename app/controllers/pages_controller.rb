class PagesController < ApplicationController
  before_action :authenticate_user!, only: %i[link_telegram refresh]

  def index
    @games = Game.includes(:network).left_joins(:results).group("games.id").order("COUNT(results.id) DESC")
  end

  def telegram
    @games = Game.includes(:network).order(:display_name)
  end

  # Re-reads the bot's inbox looking for a message from this user, by Telegram
  # username or by the account email they sent.
  def link_telegram
    FetchResult.new.score # pick up the message they just sent
    ChatId.new(current_user).set
    if current_user.reload.telegram_chat_id.present?
      redirect_to telegram_setup_path, notice: "Telegram linked. Your shared scores will come through from now on."
    else
      redirect_to telegram_setup_path, alert: "Couldn't find a message from you yet. Send the bot your email address, then try again."
    end
  end

  def refresh
    FetchResult.new.score
    redirect_back fallback_location: root_path, notice: "Checked Telegram for new scores."
  end
end
