# Re-parses every stored result's original share text with the CURRENT parsers
# and applies corrections to the derived columns (numeric_score, timer,
# secondary_timer, score, won). edition and gameday_id are verified but NEVER
# auto-changed: rows where the recomputed day disagrees with what's stored are
# reported and skipped.
#
#   bin/rails runner script/repair_results.rb            # dry run (default)
#   APPLY=1 bin/rails runner script/repair_results.rb    # write changes
#
# Back up the database first.
apply = ENV["APPLY"] == "1"
stats = Hash.new { |h, k| h[k] = Hash.new(0) }
skipped = []

Result.includes(:game).find_each do |row|
  parser = ParseResult::PARSERS[row.game.name]
  next if parser.nil?
  fresh = Result.new(game_id: row.game_id, user_id: row.user_id, original: row.original)
  parser.new(fresh).parse
  if fresh.gameday_id.nil?
    skipped << [row.id, row.game.name, "unparseable"]
    next
  end
  if fresh.gameday_id != row.gameday_id || fresh.edition.to_i != row.edition.to_i
    skipped << [row.id, row.game.name, "edition/gameday mismatch (stored #{row.edition}, recomputed #{fresh.edition})"]
    next
  end
  changes = {}
  %i[numeric_score timer secondary_timer score won].each do |col|
    changes[col] = fresh[col] if fresh[col] != row[col]
  end
  next if changes.empty?
  changes.each_key { |col| stats[row.game.name][col] += 1 }
  stats[row.game.name][:rows] += 1
  row.update!(changes) if apply
end

puts apply ? "== APPLIED ==" : "== DRY RUN (set APPLY=1 to write) =="
stats.sort.each do |game, cols|
  detail = cols.except(:rows).map { |c, n| "#{c}:#{n}" }.join(" ")
  puts format("%-18s %5d rows  (%s)", game, cols[:rows], detail)
end
puts "total rows changed: #{stats.sum { |_, c| c[:rows] }}"
if skipped.any?
  puts "\nskipped (NOT changed):"
  skipped.group_by { |_, g, r| [g, r] }.each do |(game, reason), rows|
    puts "  #{game}: #{rows.size} x #{reason}  ids=#{rows.map(&:first).first(8).join(',')}#{rows.size > 8 ? '…' : ''}"
  end
end

if apply
  puts "\nrecomputing averages…"
  Average.find_each { |a| CalculateAverage.new(a.user, a.game).average }
  puts "done."
end
