class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :name
      t.string :url
      t.string :display_name
      t.references :network, null: false, foreign_key: true
      t.string :logo

      t.timestamps
    end
  end
end
