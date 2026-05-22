# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20260520200306) do

  create_table "audio_messages", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "subj",        limit: 255
    t.string   "groupmsg",    limit: 255
    t.boolean  "publish"
    t.integer  "note_id",     limit: 4
    t.integer  "language_id", limit: 4
    t.integer  "speaker_id",  limit: 4
    t.integer  "place_id",    limit: 4
    t.string   "filename",    limit: 255
    t.integer  "duration",    limit: 4
    t.integer  "filesize",    limit: 4
    t.datetime "event_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                   default: false
  end

  create_table "blocked_hosts", force: :cascade do |t|
    t.string   "ip_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hymns", force: :cascade do |t|
    t.string   "title",      limit: 128, null: false
    t.string   "filename",   limit: 256, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "cc",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motms", force: :cascade do |t|
    t.integer  "audio_message_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: :cascade do |t|
    t.string   "title",      limit: 128,                 null: false
    t.string   "filename",   limit: 256,                 null: false
    t.integer  "speaker_id", limit: 4
    t.integer  "filesize",   limit: 4
    t.boolean  "delta",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "places", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "cc",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio",          limit: 65535
    t.string   "picture_file", limit: 512
    t.boolean  "delta",                      default: false
  end

  add_index "places", ["name"], name: "index_places_on_name", using: :btree

  create_table "speakers", force: :cascade do |t|
    t.string   "last_name",    limit: 255
    t.string   "first_name",   limit: 255
    t.string   "middle_name",  limit: 255
    t.string   "suffix",       limit: 255
    t.text     "bio",          limit: 65535
    t.string   "picture_file", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",                     default: false
    t.boolean  "delta",                      default: false
  end

  add_index "speakers", ["last_name", "middle_name", "first_name"], name: "index_speakers_on_last_name_and_middle_name_and_first_name", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                limit: 128, default: "",    null: false
    t.string   "hashed_password",      limit: 255, default: "",    null: false
    t.string   "salt",                 limit: 255,                 null: false
    t.boolean  "admin",                            default: false, null: false
    t.boolean  "activated",                        default: false, null: false
    t.integer  "lock_version",         limit: 4,   default: 0,     null: false
    t.datetime "last_visit",                                       null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "name",                 limit: 128
    t.boolean  "place_editor"
    t.boolean  "speaker_editor"
    t.boolean  "audio_message_editor"
    t.boolean  "video_editor"
    t.boolean  "tags_editor"
  end

  create_table "videos", force: :cascade do |t|
    t.string   "title",      limit: 128,                 null: false
    t.string   "filename",   limit: 256,                 null: false
    t.integer  "speaker_id", limit: 4
    t.integer  "duration",   limit: 4
    t.boolean  "delta",                  default: false
    t.datetime "event_date"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "writings", force: :cascade do |t|
    t.string   "title",      limit: 128,                 null: false
    t.string   "filename",   limit: 256,                 null: false
    t.integer  "speaker_id", limit: 4
    t.integer  "filesize",   limit: 4
    t.boolean  "delta",                  default: false
    t.datetime "event_date"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

end
