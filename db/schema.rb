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

ActiveRecord::Schema.define(version: 20140423153409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "intarray"

  create_table "project_subjects", force: true do |t|
    t.string   "zooniverse_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.boolean  "active",        default: true
  end

  add_index "project_subjects", ["active"], name: "index_project_subjects_on_active", using: :btree
  add_index "project_subjects", ["priority"], name: "index_project_subjects_on_priority", using: :btree

  create_table "subjects_to_classify", force: true do |t|
    t.integer  "subject_ids", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seen_subject_ids", default: [], array: true
  end

  add_index "users", ["seen_subject_ids"], name: "index_users_on_seen_subject_ids", using: :gin

end
