class CreateGameStats < ActiveRecord::Migration[8.0]
  def change
    create_table :game_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.decimal :average
      t.integer :played
      t.decimal :best
      t.decimal :win_percent

      t.timestamps
    end
  end
end
