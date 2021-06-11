# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_29_130956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "video_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
    t.index ["video_id"], name: "index_comments_on_video_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "pseudo"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "video_formats", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.string "source"
    t.string "resolution", default: "400x400"
    t.string "file", default: "video"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["video_id"], name: "index_video_formats_on_video_id"
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "views", default: 0
    t.boolean "enabled", default: false
    t.string "source", default: "t"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "duration", default: 0
    t.index ["user_id"], name: "index_videos_on_user_id"
  end

  add_foreign_key "comments", "users"
  add_foreign_key "comments", "videos"
  add_foreign_key "video_formats", "videos"
  add_foreign_key "videos", "users"
end
