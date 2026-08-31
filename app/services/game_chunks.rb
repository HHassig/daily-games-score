# Splits one Telegram/share message into [game_name, chunk_text] pairs.
#
# Almost every share is one game per message, matched by the longest game
# display name that prefixes line 1 ("Mini Sudoku #385..." must match Mini
# Sudoku, not a bare "Mini"; "Connections: Sports Edition" before
# "Connections"). Two exceptions:
#   - Pips bundles Easy/Medium/Hard blocks in a single share -> one chunk per
#     difficulty, routed to the pips-<difficulty> games.
#   - The Mini crossword's share is a sentence/badge URL with no game-name
#     prefix -> detected by its URL/wording.
class GameChunks
  PIPS_HEADER = /\APips\s+#[\d.,]+\s+(Easy|Medium|Hard)\b/i
  MINI_CROSSWORD = %r{Mini Crossword|badges/games/mini\.}i

  # display_names: { "mini sudoku" => "minisudoku", ... } (downcased keys)
  def self.split(text, display_names)
    text = text.to_s
    return split_pips(text) if text.match?(/\A\s*Pips\s+#/i)
    return [["minicrossword", text]] if text.match?(MINI_CROSSWORD)
    first = text.split("\n").first.to_s.strip.downcase
    name = display_names.keys.sort_by { |k| -k.length }.find { |k| first.start_with?(k) }
    name ? [[display_names[name], text]] : []
  end

  def self.split_pips(text)
    chunks = []
    current = nil
    text.split("\n").each do |line|
      if (match = line.strip.match(PIPS_HEADER))
        chunks << current if current
        current = ["pips-#{match[1].downcase}", [line]]
      elsif current
        current[1] << line
      end
    end
    chunks << current if current
    chunks.map { |name, chunk_lines| [name, chunk_lines.join("\n")] }
  end
end
