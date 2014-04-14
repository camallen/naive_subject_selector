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

ActiveRecord::Schema.define(version: 20140411162155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "project_subjects", force: true do |t|
    t.string   "zooniverse_id"
    t.integer  "priority"
    t.string   "seen_user_ids",                array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.boolean  "active",        default: true
  end

  add_index "project_subjects", ["active"], name: "index_project_subjects_on_active", using: :btree
  add_index "project_subjects", ["priority"], name: "index_project_subjects_on_priority", using: :btree
  add_index "project_subjects", ["seen_user_ids"], name: "index_project_subjects_on_seen_user_ids", using: :gin

  create_table "users", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
