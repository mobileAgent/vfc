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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111107204457) do

  create_table "audio_messages", :force => true do |t|
    t.string   "title"
    t.string   "subj"
    t.string   "groupmsg"
    t.boolean  "publish"
    t.integer  "notes_id"
    t.integer  "language_id"
    t.integer  "speaker_id"
    t.integer  "place_id"
    t.string   "filename"
    t.integer  "duration"
    t.integer  "filesize"
    t.datetime "event_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foo", :id => false, :force => true do |t|
    t.string  "speaker", :limit => 128
    t.integer "c",       :limit => 8,   :default => 0, :null => false
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "cc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motms", :force => true do |t|
    t.integer  "audio_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "cc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["name"], :name => "index_places_on_name"

  create_table "speakers", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "suffix"
    t.text     "bio"
    t.string   "picture_file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",       :default => false
  end

  add_index "speakers", ["last_name", "middle_name", "first_name"], :name => "index_speakers_on_last_name_and_middle_name_and_first_name"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
