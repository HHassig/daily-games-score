class Result < ApplicationRecord
  belongs_to :user
  belongs_to :game
  belongs_to :gameday

  def display_timer(timer)
    format("%d:%02d", timer / 60, timer % 60)
  end
end
