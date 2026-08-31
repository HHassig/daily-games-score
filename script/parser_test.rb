# Golden tests for every share-text parser, using real formats captured from
# production (English + Dutch, desktop + mobile, wins + fails).
#
# Run: ruby script/parser_test.rb   (no Rails, no DB)
require "minitest/autorun"
require_relative "parser_stub"

class ParserTest < Minitest::Test
  def assert_parsed(game, text, expected)
    got = replay(game, text)
    expected.each do |key, want|
      if want.nil?
        assert_nil got[key], "#{game} #{key} for #{text.lines.first&.strip.inspect}"
      else
        assert_equal want, got[key], "#{game} #{key} for #{text.lines.first&.strip.inspect}"
      end
    end
  end

  # --- Wordle -----------------------------------------------------------
  def test_wordle_dot_edition_hard_mode
    assert_parsed "wordle", "Wordle 1.899 4/6*\n\n⬛⬛⬛⬛⬛\n⬛⬛⬛⬛⬛\n🟩🟩🟩🟩⬛\n🟩🟩🟩🟩🟩",
      edition: 1899, numeric_score: "4/6*", timer: 4, won: true, gameday: "2026-08-31"
  end

  def test_wordle_comma_edition
    assert_parsed "wordle", "Wordle 1,555 3/6\n\n🟩🟩🟩🟩🟩",
      edition: 1555, numeric_score: "3/6", timer: 3, won: true
  end

  def test_wordle_fail
    assert_parsed "wordle", "Wordle 1.900 X/6*\n\n⬛⬛⬛⬛⬛",
      timer: 7, numeric_score: "X/6*", won: false
  end

  def test_wordle_chat_noise_is_ignored
    assert_parsed "wordle", "Wordle is hard today", gameday: nil, edition: nil, timer: nil
  end

  # --- Connections ------------------------------------------------------
  def test_connections_perfect
    assert_parsed "connections", "Connections\nPuzzle #1177\n🟨🟨🟨🟨\n🟦🟦🟦🟦\n🟩🟩🟩🟩\n🟪🟪🟪🟪",
      edition: 1177, numeric_score: "4", timer: 4, won: true, gameday: "2026-08-31"
  end

  def test_connections_loss_scores_eight
    assert_parsed "connections", "Connections\nPuzzle #1177\n🟨🟨🟨🟨\n🟦🟦🟩🟦\n🟩🟦🟩🟩\n🟪🟪🟩🟪\n🟪🟪🟦🟪",
      numeric_score: "8", timer: 8, won: false
  end

  def test_connections_chat_noise_is_ignored
    assert_parsed "connections", "Connections was brutal", gameday: nil
    assert_parsed "connections", "Connections\nPuzzle #1177", gameday: nil # grid-less
  end

  # --- Strands ----------------------------------------------------------
  def test_strands_counts_hint_bulbs
    assert_parsed "strands", "Strands #911\n“With a little elbow grease”\n💡🔵🔵🔵\n💡🔵🟡🔵\n🔵",
      edition: 911, numeric_score: "2", timer: 2, won: true, gameday: "2026-08-31"
  end

  def test_strands_no_hints
    assert_parsed "strands", "Strands #911\n“Theme”\n🔵🔵🟡🔵", numeric_score: "0", timer: 0
  end

  # --- Pinpoint ---------------------------------------------------------
  def test_pinpoint_desktop_win
    assert_parsed "pinpoint", "Pinpoint #853 | 1 guess with no mistakes\n1️⃣ | 100% match 📌\nlnkd.in/pinpoint.",
      edition: 853, numeric_score: "1 guess", timer: 1, won: true, gameday: "2026-08-31"
  end

  def test_pinpoint_desktop_dutch_truncated_body_trusts_header
    # Newer shares print ONLY the final guess line; the header is authoritative (prod id 7900).
    assert_parsed "pinpoint", "Pinpoint #719 | 2 pogingen\n2️⃣ | 100% match 📌\n🏅 Ik ben bezig met een reeks van 4- dagen!\nlnkd.in/pinpoint.",
      timer: 2, numeric_score: "2 guesses", won: true
  end

  def test_pinpoint_mobile_grid_win
    assert_parsed "pinpoint", "Pinpoint #315\n🤔 🤔 📌 ⬜ ⬜ (3/5)\nlnkd.in/pinpoint.",
      timer: 3, numeric_score: "3 guesses", won: true
  end

  def test_pinpoint_mobile_fail
    assert_parsed "pinpoint", "Pinpoint #315\n1️⃣  | 14% match\n2️⃣  | 1% match\n3️⃣  | 1% match\n4️⃣  | 4% match\n5️⃣  | 12% match\nlnkd.in/pinpoint.",
      timer: 6, numeric_score: "X/5", won: false
  end

  # --- Queens / Crossclimb ----------------------------------------------
  def test_queens_desktop_dutch_clean_numeric
    assert_parsed "queens", "Queens #326 | 2:28 en foutloos\nEerste 👑s: 🟫 🟩 ⬛\nlnkd.in/queens.",
      edition: 326, numeric_score: "2:28", timer: 148, score: "Eerste 👑s: 🟫 🟩 ⬛"
  end

  def test_queens_mobile
    assert_parsed "queens", "Queens #326\n2:28 👑\nlnkd.in/queens.",
      edition: 326, numeric_score: "2:28", timer: 148
  end

  def test_crossclimb_drops_brag_lines
    got = replay("crossclimb", "Crossclimb #853 | 0:26 with no mistakes & no hints\nFill order: 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 🔼 🔽 🪜\n🏅 I'm on a 4-day win streak!\n#AreYouSmarterThanaCEO\nlnkd.in/crossclimb.")
    assert_equal "Fill order: 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 🔼 🔽 🪜", got[:score]
    assert_equal "0:26", got[:numeric_score]
    assert_equal 26, got[:timer]
  end

  def test_crossclimb_casing_and_mobile
    assert_parsed "crossclimb", "CrossClimb #316\n0:49 🪜\nlnkd.in/crossclimb.",
      edition: 316, timer: 49, numeric_score: "0:49"
  end

  # --- Tango ------------------------------------------------------------
  def test_tango_desktop_dutch
    got = replay("tango", "Tango #146 | 0:50 en foutloos\nEerste 5 plaatsingen:\n🟨🟨🟨🟨🟨🟨\n🟨🟨🟨🟨🟨🟨\nlnkd.in/tango.")
    assert_equal "0:50", got[:numeric_score]
    assert_equal 50, got[:timer]
    assert_equal "2025-03-02", got[:gameday]
  end

  def test_tango_mobile
    assert_parsed "tango", "Tango #159\n1:00 🌗\nlnkd.in/tango.", timer: 60, numeric_score: "1:00"
  end

  # --- Zip --------------------------------------------------------------
  def test_zip_english_backtracks
    assert_parsed "zip", "Zip #4 | 0:52 🏁\nWith 1 backtrack 🛑\nlnkd.in/zip.",
      edition: 4, numeric_score: "0:52", timer: 52, secondary_timer: 1
  end

  def test_zip_dutch_backtracks
    assert_parsed "zip", "Zip #100 | 1:01 🏁\nMet 4 nieuwe pogingen 🛑\nlnkd.in/zip.", secondary_timer: 4
  end

  def test_zip_hint_count_is_not_backtracks
    assert_parsed "zip", "Zip #532 | 0:30 🏁\nWith 2 hints & no backtracks\nlnkd.in/zip.", secondary_timer: 0
  end

  def test_zip_celebrity_line_stores_nil_not_zero
    assert_parsed "zip", "Zip #40 | 1:30 🏁\nFaster than Sara Blakely's 1:49.\nlnkd.in/zip.", secondary_timer: nil
  end

  def test_zip_mobile
    assert_parsed "zip", "Zip #532 | 0:08 🏁\nWith no hints & no backtracks\nlnkd.in/zip.",
      numeric_score: "0:08", timer: 8, secondary_timer: 0, gameday: "2026-08-31"
    assert_parsed "zip", "Zip #532\n0:45 🏁\nlnkd.in/zip.", timer: 45, numeric_score: "0:45"
  end

  # --- Wend / Patches ---------------------------------------------------
  def test_wend_goldens
    assert_parsed "wend", "Wend #84 | 0:21 🌀\nWith no hints & no backtracks\nlnkd.in/wend.",
      edition: 84, timer: 21, secondary_timer: 0, gameday: "2026-08-31", numeric_score: "0:21"
    assert_parsed "wend", "Wend #84 | 0:50 🌀\nWith no hints & 6 backtracks\nlnkd.in/wend.", secondary_timer: 6
    assert_parsed "wend", "Wend #1 | 0:30 🌀\nWith no hints & no backtracks\nlnkd.in/wend.", gameday: "2026-06-09"
  end

  def test_patches_goldens
    assert_parsed "patches", "Patches #167 | 0:10 🧶\nWith no hints & no redraws\nlnkd.in/patches.",
      edition: 167, timer: 10, secondary_timer: 0, gameday: "2026-08-31", numeric_score: "0:10"
    assert_parsed "patches", "Patches #167 | 2:00 🧶\nWith 4 hints & 1 redraw\nlnkd.in/patches.", secondary_timer: 1
    assert_parsed "patches", "Patches #1 | 0:30 🧶\nWith no hints & no redraws\nlnkd.in/patches.", gameday: "2026-03-18"
  end

  # --- Mini Sudoku ------------------------------------------------------
  def test_mini_sudoku
    assert_parsed "minisudoku", "Mini Sudoku #385 | 0:36 with no hints ✏️\nThe classic game, made mini. Handcrafted by the originators of \"Sudoku.\"\nlnkd.in/minisudoku.",
      edition: 385, timer: 36, numeric_score: "0:36", secondary_timer: 0, gameday: "2026-08-31"
    assert_parsed "minisudoku", "Mini Sudoku #1 | 5:00 with 2 hints ✏️\nlnkd.in/minisudoku.",
      gameday: "2025-08-12", secondary_timer: 2
  end

  # --- Pips -------------------------------------------------------------
  def test_pips_single_block
    assert_parsed "pips-easy", "Pips #289 Easy 🟢\n0:32",
      edition: 289, timer: 32, numeric_score: "0:32", gameday: "2026-06-02"
  end

  def test_pips_cookie_and_long_time
    assert_parsed "pips-hard", "Pips #289 Hard 🔴\n8:48 🍪", timer: 528
    assert_parsed "pips-hard", "Pips #290 Hard 🔴\n1:02:44", timer: 3764
  end

  def test_pips_epoch
    assert_parsed "pips-easy", "Pips #1 Easy 🟢\n0:20", gameday: "2025-08-18"
    assert_parsed "pips-easy", "Pips #379 Easy 🟢\n0:20", gameday: "2026-08-31"
  end

  # --- The Mini ---------------------------------------------------------
  def test_mini_crossword_badge_url
    assert_parsed "minicrossword", "https://www.nytimes.com/badges/games/mini.html?d=2026-08-31&t=36&c=abcdef&smid=url-share",
      timer: 36, numeric_score: "0:36", gameday: "2026-08-31", won: true
  end

  def test_mini_crossword_sentence
    assert_parsed "minicrossword", "I solved the 8/31/2026 New York Times Mini Crossword in 1:07!",
      timer: 67, numeric_score: "1:07", gameday: "2026-08-31"
  end

  # --- CalculateSeconds -------------------------------------------------
  def test_calculate_seconds_handles_hours
    assert_equal 3764, CalculateSeconds.new("1:02:44").convert
    assert_equal 62, CalculateSeconds.new("1:02").convert
    assert_nil CalculateSeconds.new(nil).convert
  end

  # --- GameChunks -------------------------------------------------------
  NAMES = {
    "wordle" => "wordle", "connections" => "connections",
    "connections: sports edition" => "sportsconnections", "strands" => "strands",
    "pinpoint" => "pinpoint", "zip" => "zip", "wend" => "wend", "patches" => "patches",
    "tango" => "tango", "queens" => "queens", "crossclimb" => "crossclimb",
    "mini sudoku" => "minisudoku", "the mini" => "minicrossword",
  }.freeze

  def test_chunks_multi_word_and_longest_prefix
    assert_equal [["minisudoku"]], GameChunks.split("Mini Sudoku #385 | 0:36 with no hints ✏️\nlnkd.in/minisudoku.", NAMES).map { |n, _| [n] }
    assert_equal "sportsconnections", GameChunks.split("Connections: Sports Edition\nPuzzle #223\n🟡🟡🟡🟡", NAMES).first.first
    assert_equal "connections", GameChunks.split("Connections\nPuzzle #1177\n🟨🟨🟨🟨", NAMES).first.first
  end

  def test_chunks_pips_bundle_splits_by_difficulty
    text = "Pips #289 Easy 🟢\n\n0:32\n\nPips #289 Medium 🟡\n\n0:58\n\nPips #289 Hard 🔴\n\n2:43"
    chunks = GameChunks.split(text, NAMES)
    assert_equal %w[pips-easy pips-medium pips-hard], chunks.map(&:first)
    assert_includes chunks[2].last, "2:43"
  end

  def test_chunks_mini_crossword_detection
    assert_equal "minicrossword", GameChunks.split("I solved the 8/31/2026 New York Times Mini Crossword in 0:36!", NAMES).first.first
  end

  def test_chunks_unknown_chat_is_dropped
    assert_empty GameChunks.split("good morning everyone", NAMES)
  end
end
