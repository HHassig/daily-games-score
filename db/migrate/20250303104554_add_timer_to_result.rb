class AddTimerToResult < ActiveRecord::Migration[8.0]
  def change
    add_column :results, :timer, :integer
  end
end
