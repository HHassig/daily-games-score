[User, Friendship, GameStat, Game, Gameday, Network, Result].each do |model|
end


require "json"

class ImportDatabase
  def import
    JSON.parse(File.read("db/exported_users.json")).each { |item| User.create!(item) }
    JSON.parse(File.read("db/exported_friendships.json")).each { |item| Friendship.create!(item) }
    JSON.parse(File.read("db/exported_gamedays.json")).each { |item| Gameday.create!(item) }
    JSON.parse(File.read("db/exported_results.json")).each { |item| Result.create!(item) }
    JSON.parse(File.read("db/exported_game_stats.json")).each { |item| GameStat.create!(item) }
  end
end
