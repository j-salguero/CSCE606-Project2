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

<<<<<<< HEAD
ActiveRecord::Schema[8.0].define(version: 2025_10_30_232328) do
  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
=======
ActiveRecord::Schema[8.0].define(version: 2025_11_02_140811) do
  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.integer "year"
    t.integer "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "genre"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_provider"
    t.string "api_artist_id"
    t.string "discogs_id"
    t.string "discogs_uri"
>>>>>>> main
  end

  create_table "collection_items", force: :cascade do |t|
    t.string "user_id"
    t.string "artist_id"
    t.datetime "added_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
<<<<<<< HEAD
    t.string "title"
    t.string "artist"
=======
    t.integer "album_id", null: false
    t.index ["album_id"], name: "index_collection_items_on_album_id"
>>>>>>> main
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.string "user_id"
    t.string "artist_id"
    t.datetime "added_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "artist"
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "collection_items", "albums"
end
