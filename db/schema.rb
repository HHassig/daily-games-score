# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_01_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "averages", force: :cascade do |t|
    t.decimal "score"
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_averages_on_game_id"
    t.index ["user_id", "game_id"], name: "index_averages_on_user_id_and_game_id", unique: true
    t.index ["user_id"], name: "index_averages_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.decimal "average"
    t.integer "played"
    t.decimal "best"
    t.decimal "win_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_stats_on_game_id"
    t.index ["user_id"], name: "index_game_stats_on_user_id"
  end

  create_table "gamedays", force: :cascade do |t|
    t.string "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_gamedays_on_date", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "display_name"
    t.bigint "network_id", null: false
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "timed"
    t.index ["network_id"], name: "index_games_on_network_id"
  end

  create_table "networks", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "score"
    t.bigint "game_id", null: false
    t.bigint "gameday_id", null: false
    t.integer "edition"
    t.string "original"
    t.string "numeric_score"
    t.boolean "won"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "timer"
    t.integer "secondary_timer"
    t.index ["game_id"], name: "index_results_on_game_id"
    t.index ["gameday_id"], name: "index_results_on_gameday_id"
    t.index ["user_id", "game_id", "gameday_id"], name: "index_results_on_user_game_gameday", unique: true
    t.index ["user_id"], name: "index_results_on_user_id"
  end

  create_table "telegram_contacts", force: :cascade do |t|
    t.string "chat_id", null: false
    t.string "username"
    t.text "last_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_telegram_contacts_on_chat_id", unique: true
    t.index ["username"], name: "index_telegram_contacts_on_username"
  end

  create_table "telegram_states", force: :cascade do |t|
    t.bigint "last_update_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "telegram_username"
    t.string "telegram_chat_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "averages", "games"
  add_foreign_key "averages", "users"
  add_foreign_key "game_stats", "games"
  add_foreign_key "game_stats", "users"
  add_foreign_key "games", "networks"
  add_foreign_key "results", "gamedays"
  add_foreign_key "results", "games"
  add_foreign_key "results", "users"
end
