class Game < ApplicationRecord
  belongs_to :network
  has_many :results

  # The three Pips difficulties are separate rows but present as one game.
  def pips?
    name.to_s.start_with?("pips-")
  end

  # Label used wherever the Pips family shows as a single entry.
  def tile_name
    pips? ? "Pips" : display_name
  end
end
