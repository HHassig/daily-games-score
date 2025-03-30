class AddTimedToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :timed, :boolean
  end
end
