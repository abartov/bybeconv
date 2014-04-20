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

ActiveRecord::Schema.define(:version => 20140420152251) do

  create_table "expressions", :force => true do |t|
    t.string   "title"
    t.string   "form"
    t.string   "date"
    t.string   "language"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "expressions_people", :id => false, :force => true do |t|
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "expression_id"
    t.integer  "person_id"
  end

  create_table "html_dirs", :force => true do |t|
    t.string   "path"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "html_files", :force => true do |t|
    t.string   "path"
    t.string   "url"
    t.string   "status"
    t.string   "problem"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tables"
    t.boolean  "footnotes"
    t.boolean  "images"
    t.string   "nikkud"
    t.boolean  "line_numbers"
    t.string   "indentation"
    t.string   "headings"
    t.string   "orig_mtime"
    t.string   "orig_ctime"
    t.boolean  "stripped_nikkud"
    t.string   "orig_lang"
    t.string   "year_published"
    t.string   "orig_year_published"
  end

  add_index "html_files", ["path"], :name => "index_html_files_on_path"

  create_table "html_files_manifestations", :id => false, :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "html_file_id"
    t.integer  "manifestation_id"
  end

  create_table "manifestations", :force => true do |t|
    t.string   "title"
    t.string   "responsibility_statement"
    t.string   "edition"
    t.string   "identifier"
    t.string   "medium"
    t.string   "publisher"
    t.string   "publication_place"
    t.string   "publication_date"
    t.string   "series_statement"
    t.text     "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.text     "markdown"
  end

  create_table "manifestations_people", :id => false, :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "manifestation_id"
    t.integer  "person_id"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "dates"
    t.string   "title"
    t.string   "other_designation"
    t.string   "affiliation"
    t.string   "country"
    t.text     "comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "viaf_id"
    t.string   "nli_id"
  end

  create_table "proofs", :force => true do |t|
    t.string   "from"
    t.string   "about"
    t.text     "what"
    t.boolean  "subscribe"
    t.string   "status"
    t.string   "assignee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.boolean  "admin"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "editor"
  end

  create_table "works", :force => true do |t|
    t.string   "title"
    t.string   "form"
    t.string   "date"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "works_people", :id => false, :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "work_id"
    t.integer  "person_id"
  end

end
