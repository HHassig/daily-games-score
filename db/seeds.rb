# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# LinkedIn's newer daily puzzles. Idempotent so this can be re-run at any time.
linkedin = Network.find_or_create_by!(name: "Linkedin") { |n| n.url = "https://linkedin.com/games" }

[
  { name: "wend",    display_name: "Wend",    logo: "/games/wend.svg" },
  { name: "patches", display_name: "Patches", logo: "/games/patches.svg" }
].each do |attrs|
  game = Game.find_or_initialize_by(name: attrs[:name])
  game.update!(
    display_name: attrs[:display_name],
    url: "https://linkedin.com/games/#{attrs[:name]}",
    logo: attrs[:logo],
    network: linkedin,
    timed: true
  )
end
