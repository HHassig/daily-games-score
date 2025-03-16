class CreateAverages < ActiveRecord::Migration[8.0]
  def change
    create_table :averages do |t|
      t.decimal :score
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
