class AddIntegrityIndexes < ActiveRecord::Migration[8.0]
  def up
    # Merge duplicate gamedays (same date string), repointing results first.
    execute <<~SQL
      UPDATE results SET gameday_id = k.keep_id
      FROM gamedays g
      JOIN (SELECT date, MIN(id) AS keep_id FROM gamedays GROUP BY date HAVING COUNT(*) > 1) k
        ON g.date = k.date
      WHERE results.gameday_id = g.id AND g.id <> k.keep_id
    SQL
    execute <<~SQL
      DELETE FROM gamedays g
      USING (SELECT date, MIN(id) AS keep_id FROM gamedays GROUP BY date HAVING COUNT(*) > 1) k
      WHERE g.date = k.date AND g.id <> k.keep_id
    SQL
    # Junk gamedays created by unvalidated ?date= params - only ones no result references.
    execute <<~SQL
      DELETE FROM gamedays
      WHERE date !~ '^\\d{4}-\\d{2}-\\d{2}$'
        AND id NOT IN (SELECT DISTINCT gameday_id FROM results)
    SQL
    # Duplicate averages from score-in-the-finder find_or_create_by! (keep oldest).
    execute <<~SQL
      DELETE FROM averages a USING averages b
      WHERE a.user_id = b.user_id AND a.game_id = b.game_id AND a.id > b.id
    SQL
    # Duplicate results guard (corpus audit found zero; defensive for the race window).
    execute <<~SQL
      DELETE FROM results a USING results b
      WHERE a.user_id = b.user_id AND a.game_id = b.game_id AND a.gameday_id = b.gameday_id AND a.id > b.id
    SQL

    add_index :results, [:user_id, :game_id, :gameday_id], unique: true, name: "index_results_on_user_game_gameday"
    add_index :gamedays, :date, unique: true
    add_index :averages, [:user_id, :game_id], unique: true
  end

  def down
    remove_index :results, name: "index_results_on_user_game_gameday"
    remove_index :gamedays, :date
    remove_index :averages, [:user_id, :game_id]
  end
end
