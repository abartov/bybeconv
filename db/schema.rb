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

ActiveRecord::Schema.define(version: 20161109063540) do

  create_table "api_keys", force: :cascade do |t|
    t.string   "email",       limit: 255
    t.string   "description", limit: 255
    t.string   "key",         limit: 255
    t.integer  "status",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "api_keys", ["email"], name: "index_api_keys_on_email", unique: true, using: :btree

  create_table "expressions", force: :cascade do |t|
    t.string   "title",                limit: 255
    t.string   "form",                 limit: 255
    t.string   "date",                 limit: 255
    t.string   "language",             limit: 255
    t.text     "comment",              limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "copyrighted"
    t.date     "copyright_expiration"
  end

  create_table "expressions_manifestations", id: false, force: :cascade do |t|
    t.integer "expression_id",    limit: 4
    t.integer "manifestation_id", limit: 4
  end

  create_table "expressions_people", id: false, force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "expression_id", limit: 4
    t.integer  "person_id",     limit: 4
  end

  create_table "expressions_works", id: false, force: :cascade do |t|
    t.integer "expression_id", limit: 4
    t.integer "work_id",       limit: 4
  end

  create_table "external_links", force: :cascade do |t|
    t.string   "url",              limit: 255
    t.string   "linktype",         limit: 255
    t.integer  "status",           limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "manifestation_id", limit: 4
  end

  create_table "html_dirs", force: :cascade do |t|
    t.string   "path",            limit: 255
    t.string   "author",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "need_resequence"
    t.boolean  "public_domain"
    t.integer  "person_id",       limit: 4
  end

  create_table "html_files", force: :cascade do |t|
    t.string   "path",                limit: 255
    t.string   "url",                 limit: 255
    t.string   "status",              limit: 255
    t.string   "problem",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tables"
    t.boolean  "footnotes"
    t.boolean  "images"
    t.string   "nikkud",              limit: 255
    t.boolean  "line_numbers"
    t.string   "indentation",         limit: 255
    t.string   "headings",            limit: 255
    t.string   "orig_mtime",          limit: 255
    t.string   "orig_ctime",          limit: 255
    t.boolean  "stripped_nikkud"
    t.string   "orig_lang",           limit: 255
    t.string   "year_published",      limit: 255
    t.string   "orig_year_published", limit: 255
    t.integer  "seqno",               limit: 4
    t.string   "orig_author",         limit: 255
    t.string   "orig_author_url",     limit: 255
    t.integer  "person_id",           limit: 4
  end

  add_index "html_files", ["path"], name: "index_html_files_on_path", using: :btree

  create_table "html_files_manifestations", id: false, force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "html_file_id",     limit: 4
    t.integer  "manifestation_id", limit: 4
  end

  create_table "manifestations", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.string   "responsibility_statement", limit: 255
    t.string   "edition",                  limit: 255
    t.string   "identifier",               limit: 255
    t.string   "medium",                   limit: 255
    t.string   "publisher",                limit: 255
    t.string   "publication_place",        limit: 255
    t.string   "publication_date",         limit: 255
    t.string   "series_statement",         limit: 255
    t.text     "comment",                  limit: 16777215
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "markdown",                 limit: 16777215
  end

  create_table "manifestations_people", id: false, force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "manifestation_id", limit: 4
    t.integer  "person_id",        limit: 4
  end

  create_table "people", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "dates",             limit: 255
    t.string   "title",             limit: 255
    t.string   "other_designation", limit: 255
    t.string   "affiliation",       limit: 255
    t.string   "country",           limit: 255
    t.text     "comment",           limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "viaf_id",           limit: 255
    t.string   "nli_id",            limit: 255
    t.integer  "toc_id",            limit: 4
    t.boolean  "public_domain"
  end

  create_table "people_works", id: false, force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "work_id",    limit: 4
    t.integer  "person_id",  limit: 4
  end

  create_table "proofs", force: :cascade do |t|
    t.string   "from",             limit: 255
    t.string   "about",            limit: 255
    t.text     "what",             limit: 65535
    t.boolean  "subscribe"
    t.string   "status",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "html_file_id",     limit: 4
    t.integer  "resolved_by",      limit: 4
    t.text     "highlight",        limit: 65535
    t.integer  "reported_by",      limit: 4
    t.integer  "manifestation_id", limit: 4
  end

  create_table "recommendations", force: :cascade do |t|
    t.string   "from",             limit: 255
    t.string   "about",            limit: 255
    t.string   "what",             limit: 255
    t.boolean  "subscribe"
    t.string   "status",           limit: 255
    t.integer  "resolved_by",      limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "html_file_id",     limit: 4
    t.integer  "recommended_by",   limit: 4
    t.integer  "manifestation_id", limit: 4
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",           limit: 4
    t.integer  "manifestation_id", limit: 4
    t.integer  "status",           limit: 4
    t.integer  "suggested_by",     limit: 4
    t.integer  "approved_by",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "status",     limit: 4
    t.integer  "created_by", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tocs", force: :cascade do |t|
    t.text     "toc",        limit: 65535
    t.string   "status",     limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "email",            limit: 255
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.string   "oauth_token",      limit: 255
    t.datetime "oauth_expires_at"
    t.boolean  "admin"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "editor"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "works", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "form",       limit: 255
    t.string   "date",       limit: 255
    t.text     "comment",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "genre",      limit: 255
  end

end
