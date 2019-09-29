# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190923105637) do

  create_table "characters", force: :cascade do |t|
    t.integer "game_title"
    t.integer "main_character"
    t.integer "sub_character1"
    t.integer "sub_character2"
    t.integer "sub_character3"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.integer "ranking"
    t.integer "user_id"
    t.integer "tournament_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_participants_on_tournament_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.integer "id_number"
    t.string "name"
    t.integer "game_title"
    t.string "elimination_type"
    t.datetime "start_time"
    t.string "url"
    t.text "description"
    t.integer "particepants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: true, null: false
    t.string "status"
    t.integer "master"
    t.boolean "group_stage_enabled"
    t.boolean "hold_third_place_match", default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "name_reading"
    t.string "email"
    t.integer "slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "twitter_id"
    t.boolean "twitter_private", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
