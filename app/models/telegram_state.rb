class TelegramState < ApplicationRecord
  def self.current
    first || create!
  end
end
