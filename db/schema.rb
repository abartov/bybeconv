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

ActiveRecord::Schema.define(version: 20160924005743) do

  create_table "api_keys", force: true do |t|
    t.string   "email"
    t.string   "description"
    t.string   "key"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["email"], name: "index_api_keys_on_email", unique: true, using: :btree

  create_table "expressions", force: true do |t|
    t.string   "title"
    t.string   "form"
    t.string   "date"
    t.string   "language"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "copyrighted"
    t.date     "copyright_expiration"
  end

  create_table "expressions_manifestations", id: false, force: true do |t|
    t.integer "expression_id"
    t.integer "manifestation_id"
  end

  add_index "expressions_manifestations", ["expression_id"], name: "index_expressions_manifestations_on_expression_id", using: :btree
  add_index "expressions_manifestations", ["manifestation_id"], name: "index_expressions_manifestations_on_manifestation_id", using: :btree

  create_table "expressions_people", id: false, force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expression_id"
    t.integer  "person_id"
  end

  create_table "expressions_works", id: false, force: true do |t|
    t.integer "expression_id"
    t.integer "work_id"
  end

  add_index "expressions_works", ["expression_id"], name: "index_expressions_works_on_expression_id", using: :btree
  add_index "expressions_works", ["work_id"], name: "index_expressions_works_on_work_id", using: :btree

  create_table "external_links", force: true do |t|
    t.string   "url"
    t.string   "linktype"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manifestation_id"
  end

  create_table "html_dirs", force: true do |t|
    t.string   "path"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "need_resequence"
    t.integer  "person_id"
    t.boolean  "public_domain"
  end

  create_table "html_files", force: true do |t|
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
    t.integer  "seqno"
    t.string   "orig_author"
    t.string   "orig_author_url"
    t.integer  "person_id"
  end

  add_index "html_files", ["path"], name: "index_html_files_on_path", using: :btree

  create_table "html_files_manifestations", id: false, force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "html_file_id"
    t.integer  "manifestation_id"
  end

  create_table "manifestations", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "markdown"
  end

  create_table "manifestations_people", id: false, force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manifestation_id"
    t.integer  "person_id"
  end

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "dates"
    t.string   "title"
    t.string   "other_designation"
    t.string   "affiliation"
    t.string   "country"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "viaf_id"
    t.string   "nli_id"
    t.integer  "toc_id"
  end

  create_table "people_works", id: false, force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "work_id"
    t.integer  "person_id"
  end

  create_table "proofs", force: true do |t|
    t.string   "from"
    t.string   "about"
    t.text     "what"
    t.boolean  "subscribe"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "html_file_id"
    t.integer  "resolved_by"
    t.text     "highlight"
    t.integer  "reported_by"
    t.integer  "manifestation_id"
  end

  create_table "recommendations", force: true do |t|
    t.string   "from"
    t.string   "about"
    t.string   "what"
    t.boolean  "subscribe"
    t.string   "status"
    t.integer  "resolved_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "html_file_id"
    t.integer  "recommended_by"
    t.integer  "manifestation_id"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "manifestation_id"
    t.integer  "status"
    t.integer  "suggested_by"
    t.integer  "approved_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "status"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tocs", force: true do |t|
    t.text     "toc"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "editor"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 2147483647
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "works", force: true do |t|
    t.string   "title"
    t.string   "form"
    t.string   "date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "genre"
  end

end
