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

ActiveRecord::Schema[7.2].define(version: 2025_07_20_160502) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "study_answers", force: :cascade do |t|
    t.bigint "study_challenge_id", null: false
    t.string "user_answer"
    t.string "correct_answer"
    t.text "explanation"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_challenge_id"], name: "index_study_answers_on_study_challenge_id"
    t.index ["user_id"], name: "index_study_answers_on_user_id"
  end

  create_table "study_badges", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "icon", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_challenges", force: :cascade do |t|
    t.bigint "study_log_id", null: false
    t.text "ai_question"
    t.text "user_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["study_log_id"], name: "index_study_challenges_on_study_log_id"
  end

  create_table "study_comments", force: :cascade do |t|
    t.bigint "study_log_id"
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["study_log_id"], name: "index_study_comments_on_study_log_id"
    t.index ["user_id"], name: "index_study_comments_on_user_id"
  end

  create_table "study_genres", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_study_genres_on_user_id"
  end

  create_table "study_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "study_log_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_log_id"], name: "index_study_likes_on_study_log_id"
    t.index ["user_id", "study_log_id"], name: "index_study_likes_on_user_id_and_study_log_id", unique: true
    t.index ["user_id"], name: "index_study_likes_on_user_id"
  end

  create_table "study_logs", force: :cascade do |t|
    t.string "content", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.bigint "user_id"
    t.date "date"
    t.integer "total"
    t.bigint "study_genre_id"
    t.integer "count"
    t.integer "study_reminder_id"
    t.index ["study_genre_id"], name: "index_study_logs_on_study_genre_id"
    t.index ["study_reminder_id"], name: "index_study_logs_on_study_reminder_id"
    t.index ["user_id"], name: "index_study_logs_on_user_id"
  end

  create_table "study_reminders", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["user_id"], name: "index_study_reminders_on_user_id"
  end

  create_table "user_study_badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "study_badge_id", null: false
    t.datetime "earned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_badge_id"], name: "index_user_study_badges_on_study_badge_id"
    t.index ["user_id"], name: "index_user_study_badges_on_user_id"
  end

  create_table "user_study_genres", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "study_genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_genre_id"], name: "index_user_study_genres_on_study_genre_id"
    t.index ["user_id"], name: "index_user_study_genres_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "profile_image"
    t.text "self_introduction"
    t.string "provider"
    t.string "uid"
    t.text "withdrawal_reason"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "study_answers", "study_challenges"
  add_foreign_key "study_answers", "users"
  add_foreign_key "study_challenges", "study_logs"
  add_foreign_key "study_comments", "study_logs"
  add_foreign_key "study_comments", "users"
  add_foreign_key "study_genres", "users"
  add_foreign_key "study_likes", "study_logs"
  add_foreign_key "study_likes", "users"
  add_foreign_key "study_logs", "study_genres"
  add_foreign_key "study_logs", "study_reminders"
  add_foreign_key "study_logs", "users"
  add_foreign_key "study_reminders", "users"
  add_foreign_key "user_study_badges", "study_badges"
  add_foreign_key "user_study_badges", "users"
  add_foreign_key "user_study_genres", "study_genres"
  add_foreign_key "user_study_genres", "users"
end
