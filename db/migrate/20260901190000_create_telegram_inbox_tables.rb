class CreateTelegramInboxTables < ActiveRecord::Migration[8.0]
  def change
    # Everyone who has messaged the bot, so an account can still be linked
    # after the update itself has been acknowledged and dropped by Telegram.
    create_table :telegram_contacts do |t|
      t.string :chat_id, null: false
      t.string :username
      t.text :last_message
      t.timestamps
      t.index :chat_id, unique: true
      t.index :username
    end

    # Singleton row holding the getUpdates offset, so the poller acknowledges
    # what it has processed instead of re-reading the same 24h buffer forever.
    create_table :telegram_states do |t|
      t.bigint :last_update_id
      t.timestamps
    end
  end
end
