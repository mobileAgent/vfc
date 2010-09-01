# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100901011733) do

  create_table "foo", :id => false, :force => true do |t|
    t.string  "speaker", :limit => 128
    t.integer "c",       :limit => 8,   :default => 0, :null => false
  end

  create_table "laguages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "load_200806", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200806", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200807", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200807", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200809", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200809", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200902", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200902", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200905", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200905", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200906", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200906", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200907", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200907", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_200909", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_200909", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201001", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201001", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201002", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201002", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201003", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201003", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201004", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201004", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201005", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201005", ["groupmsg"], :name => "groupmsg_index"

  create_table "load_201006", :force => true do |t|
    t.string    "msg",          :limit => 128
    t.boolean   "changed"
    t.string    "speaker",      :limit => 128
    t.string    "subj",         :limit => 128
    t.string    "groupmsg",     :limit => 16
    t.string    "date",         :limit => 16
    t.string    "obs_call",     :limit => 16
    t.string    "obs_grouping", :limit => 16
    t.timestamp "add_date",                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",     :limit => 512
    t.integer   "notes_id"
    t.string    "language",     :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                 :null => false
    t.string    "duration",     :limit => 16
    t.integer   "filesize"
  end

  add_index "load_201006", ["groupmsg"], :name => "groupmsg_index"

  create_table "motms", :force => true do |t|
    t.integer  "audio_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "speakers", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "suffix"
    t.text     "bio"
    t.string   "picture_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "vfc", :force => true do |t|
    t.string    "msg",           :limit => 128
    t.string    "speaker_name",  :limit => 128
    t.string    "subj",          :limit => 128
    t.string    "groupmsg",      :limit => 16
    t.string    "date",          :limit => 16
    t.string    "obs_call",      :limit => 16
    t.string    "obs_grouping",  :limit => 16
    t.timestamp "add_date",                                    :null => false
    t.boolean   "download"
    t.boolean   "publish"
    t.string    "filename",      :limit => 512
    t.integer   "notes_id"
    t.string    "language_name", :limit => 16
    t.integer   "speaker_id"
    t.timestamp "change_date",                                 :null => false
    t.string    "duration",      :limit => 16
    t.integer   "filesize"
    t.integer   "language_id"
    t.integer   "place_id",                     :default => 0
  end

  add_index "vfc", ["groupmsg"], :name => "groupmsg_index"

end
