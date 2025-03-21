class AddSecondaryTimerToResults < ActiveRecord::Migration[8.0]
  def change
    add_column :results, :secondary_timer, :integer
  end
end
