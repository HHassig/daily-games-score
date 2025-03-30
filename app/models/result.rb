class Result < ApplicationRecord
  belongs_to :user
  belongs_to :game

  def display_timer(timer)
    format("%d:%02d", timer / 60, timer % 60)
  end
end
