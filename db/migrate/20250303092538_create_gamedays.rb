class CreateGamedays < ActiveRecord::Migration[8.0]
  def change
    create_table :gamedays do |t|
      t.string :date

      t.timestamps
    end
  end
end
