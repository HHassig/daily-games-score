class CreateResults < ActiveRecord::Migration[8.0]
  def change
    create_table :results do |t|
      t.references :user, null: false, foreign_key: true
      t.string :score
      t.references :game, null: false, foreign_key: true
      t.references :gameday, null: false, foreign_key: true
      t.integer :edition
      t.string :original
      t.string :numeric_score
      t.boolean :won

      t.timestamps
    end
  end
end
