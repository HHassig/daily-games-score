# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Newer daily puzzles. Idempotent so this can be re-run at any time.
linkedin = Network.find_or_create_by!(name: "Linkedin") { |n| n.url = "https://linkedin.com/games" }
nyt = Network.find_or_create_by!(name: "New York Times") { |n| n.url = "https://nytimes.com/games" }

[
  { name: "wend",       display_name: "Wend",        logo: "/games/wend.svg",       network: linkedin, url: "https://linkedin.com/games/wend" },
  { name: "patches",    display_name: "Patches",     logo: "/games/patches.svg",    network: linkedin, url: "https://linkedin.com/games/patches" },
  { name: "minisudoku", display_name: "Mini Sudoku", logo: "/games/minisudoku.svg", network: linkedin, url: "https://linkedin.com/games/minisudoku" },
  { name: "minicrossword", display_name: "The Mini", logo: "/games/mini.svg",       network: nyt,      url: "https://www.nytimes.com/crosswords/game/mini" },
  { name: "pips-easy",   display_name: "Pips Easy",   logo: "/games/pips.svg", network: nyt, url: "https://www.nytimes.com/games/pips" },
  { name: "pips-medium", display_name: "Pips Medium", logo: "/games/pips.svg", network: nyt, url: "https://www.nytimes.com/games/pips" },
  { name: "pips-hard",   display_name: "Pips Hard",   logo: "/games/pips.svg", network: nyt, url: "https://www.nytimes.com/games/pips" }
].each do |attrs|
  game = Game.find_or_initialize_by(name: attrs[:name])
  game.update!(attrs.merge(timed: true))
end
