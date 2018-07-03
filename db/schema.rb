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

ActiveRecord::Schema.define(version: 20180703060703) do

  create_table "aboutnesses", force: :cascade do |t|
    t.integer  "work_id",        limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "status",         limit: 4
    t.integer  "wikidata_qid",   limit: 4
    t.integer  "aboutable_id",   limit: 4
    t.string   "aboutable_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "wikidata_label", limit: 255
  end

  add_index "aboutnesses", ["aboutable_type", "aboutable_id"], name: "index_aboutnesses_on_aboutable_type_and_aboutable_id", using: :btree
  add_index "aboutnesses", ["user_id"], name: "index_aboutnesses_on_user_id", using: :btree
  add_index "aboutnesses", ["wikidata_qid"], name: "index_aboutnesses_on_wikidata_qid", using: :btree
  add_index "aboutnesses", ["work_id"], name: "index_aboutnesses_on_work_id", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "email",       limit: 255
    t.string   "description", limit: 255
    t.string   "key",         limit: 255
    t.integer  "status",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "api_keys", ["email"], name: "index_api_keys_on_email", unique: true, using: :btree

  create_table "bib_sources", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.integer  "source_type",  limit: 4
    t.string   "url",          limit: 255
    t.integer  "port",         limit: 4
    t.string   "api_key",      limit: 255
    t.text     "comments",     limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "status",       limit: 4
    t.string   "institution",  limit: 255
    t.string   "item_pattern", limit: 2048
  end

  create_table "creations", force: :cascade do |t|
    t.integer  "work_id",    limit: 4
    t.integer  "person_id",  limit: 4
    t.integer  "role",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "creations", ["person_id"], name: "index_creations_on_person_id", using: :btree
  add_index "creations", ["work_id"], name: "index_creations_on_work_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "expressions", force: :cascade do |t|
    t.string   "title",                limit: 255
    t.string   "form",                 limit: 255
    t.string   "date",                 limit: 255
    t.string   "language",             limit: 255
    t.text     "comment",              limit: 16777215
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "copyrighted"
    t.date     "copyright_expiration"
    t.string   "genre",                limit: 255
    t.boolean  "translation"
    t.string   "source_edition",       limit: 255
  end

  create_table "expressions_manifestations", id: false, force: :cascade do |t|
    t.integer "expression_id",    limit: 4
    t.integer "manifestation_id", limit: 4
  end

  add_index "expressions_manifestations", ["expression_id"], name: "index_expressions_manifestations_on_expression_id", using: :btree
  add_index "expressions_manifestations", ["manifestation_id"], name: "index_expressions_manifestations_on_manifestation_id", using: :btree

  create_table "expressions_works", id: false, force: :cascade do |t|
    t.integer "expression_id", limit: 4
    t.integer "work_id",       limit: 4
  end

  add_index "expressions_works", ["expression_id"], name: "index_expressions_works_on_expression_id", using: :btree
  add_index "expressions_works", ["work_id"], name: "index_expressions_works_on_work_id", using: :btree

  create_table "external_links", force: :cascade do |t|
    t.string   "url",              limit: 255
    t.integer  "linktype",         limit: 4
    t.integer  "status",           limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "manifestation_id", limit: 4
    t.string   "description",      limit: 255
  end

  create_table "featured_author_features", force: :cascade do |t|
    t.datetime "fromdate"
    t.datetime "todate"
    t.integer  "featured_author_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "featured_author_features", ["featured_author_id"], name: "index_featured_author_features_on_featured_author_id", using: :btree

  create_table "featured_authors", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "user_id",    limit: 4
    t.integer  "person_id",  limit: 4
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "featured_authors", ["person_id"], name: "index_featured_authors_on_person_id", using: :btree
  add_index "featured_authors", ["user_id"], name: "index_featured_authors_on_user_id", using: :btree

  create_table "featured_content_features", force: :cascade do |t|
    t.integer  "featured_content_id", limit: 4
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "featured_content_features", ["featured_content_id"], name: "index_featured_content_features_on_featured_content_id", using: :btree

  create_table "featured_contents", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.integer  "manifestation_id", limit: 4
    t.integer  "person_id",        limit: 4
    t.text     "body",             limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "external_link",    limit: 255
    t.integer  "user_id_id",       limit: 4
    t.integer  "user_id",          limit: 4
  end

  add_index "featured_contents", ["manifestation_id"], name: "index_featured_contents_on_manifestation_id", using: :btree
  add_index "featured_contents", ["person_id"], name: "index_featured_contents_on_person_id", using: :btree
  add_index "featured_contents", ["user_id"], name: "index_featured_contents_on_user_id", using: :btree
  add_index "featured_contents", ["user_id_id"], name: "index_featured_contents_on_user_id_id", using: :btree

  create_table "holdings", force: :cascade do |t|
    t.integer  "publication_id", limit: 4
    t.string   "source_id",      limit: 255
    t.string   "source_name",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "status",         limit: 4
  end

  add_index "holdings", ["publication_id"], name: "index_holdings_on_publication_id", using: :btree

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
    t.string   "genre",               limit: 255
    t.boolean  "paras_condensed",                        default: false
    t.integer  "translator_id",       limit: 4
    t.integer  "assignee_id",         limit: 4
    t.text     "comments",            limit: 65535
    t.string   "title",               limit: 255
    t.string   "doc_file_name",       limit: 255
    t.string   "doc_content_type",    limit: 255
    t.integer  "doc_file_size",       limit: 4
    t.datetime "doc_updated_at"
    t.text     "markdown",            limit: 4294967295
    t.string   "publisher",           limit: 255
  end

  add_index "html_files", ["assignee_id"], name: "index_html_files_on_assignee_id", using: :btree
  add_index "html_files", ["path"], name: "index_html_files_on_path", using: :btree
  add_index "html_files", ["url"], name: "index_html_files_on_url", using: :btree

  create_table "html_files_manifestations", id: false, force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "html_file_id",     limit: 4
    t.integer  "manifestation_id", limit: 4
  end

  add_index "html_files_manifestations", ["html_file_id"], name: "index_html_files_manifestations_on_html_file_id", using: :btree
  add_index "html_files_manifestations", ["manifestation_id"], name: "index_html_files_manifestations_on_manifestation_id", using: :btree

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type", limit: 255
    t.integer  "impressionable_id",   limit: 4
    t.integer  "user_id",             limit: 4
    t.string   "controller_name",     limit: 255
    t.string   "action_name",         limit: 255
    t.string   "view_name",           limit: 255
    t.string   "request_hash",        limit: 255
    t.string   "ip_address",          limit: 255
    t.string   "session_hash",        limit: 255
    t.text     "message",             limit: 16777215
    t.text     "referrer",            limit: 16777215
    t.text     "params",              limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: {"impressionable_type"=>nil, "impressionable_id"=>nil, "params"=>255}, using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "legacy_recommendations", force: :cascade do |t|
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

  create_table "list_items", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "listkey",    limit: 255
    t.integer  "item_id",    limit: 4
    t.string   "item_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "list_items", ["item_type", "item_id"], name: "index_list_items_on_item_type_and_item_id", using: :btree
  add_index "list_items", ["listkey", "item_id"], name: "index_list_items_on_listkey_and_item_id", using: :btree
  add_index "list_items", ["listkey", "user_id", "item_id"], name: "index_list_items_on_listkey_and_user_id_and_item_id", using: :btree
  add_index "list_items", ["listkey"], name: "index_list_items_on_listkey", using: :btree
  add_index "list_items", ["user_id"], name: "index_list_items_on_user_id", using: :btree

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
    t.string   "cached_people",            limit: 255
    t.integer  "impressions_count",        limit: 4
    t.text     "cached_heading_lines",     limit: 65535
    t.boolean  "conversion_verified"
  end

  add_index "manifestations", ["created_at"], name: "index_manifestations_on_created_at", using: :btree
  add_index "manifestations", ["impressions_count"], name: "index_manifestations_on_impressions_count", using: :btree

  create_table "manifestations_people", id: false, force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "manifestation_id", limit: 4
    t.integer  "person_id",        limit: 4
  end

  add_index "manifestations_people", ["manifestation_id"], name: "index_manifestations_people_on_manifestation_id", using: :btree
  add_index "manifestations_people", ["person_id"], name: "index_manifestations_people_on_person_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.string   "dates",                      limit: 255
    t.string   "title",                      limit: 255
    t.string   "other_designation",          limit: 1024
    t.string   "affiliation",                limit: 255
    t.string   "country",                    limit: 255
    t.text     "comment",                    limit: 16777215
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "viaf_id",                    limit: 255
    t.string   "nli_id",                     limit: 255
    t.integer  "toc_id",                     limit: 4
    t.boolean  "public_domain"
    t.integer  "period_id",                  limit: 4
    t.text     "wikipedia_snippet",          limit: 16777215
    t.string   "wikipedia_url",              limit: 1024
    t.string   "image_url",                  limit: 1024
    t.string   "profile_image_file_name",    limit: 255
    t.string   "profile_image_content_type", limit: 255
    t.integer  "profile_image_file_size",    limit: 4
    t.datetime "profile_image_updated_at"
    t.integer  "wikidata_id",                limit: 4
    t.string   "birthdate",                  limit: 255
    t.string   "deathdate",                  limit: 255
    t.boolean  "metadata_approved",                           default: false
    t.integer  "gender",                     limit: 4
    t.integer  "impressions_count",          limit: 4
    t.string   "blog_category_url",          limit: 255
  end

  add_index "people", ["impressions_count"], name: "index_people_on_impressions_count", using: :btree

  create_table "periods", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "comments",      limit: 16777215
    t.string   "wikipedia_url", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "proofs", force: :cascade do |t|
    t.string   "from",             limit: 255
    t.string   "about",            limit: 255
    t.text     "what",             limit: 16777215
    t.boolean  "subscribe"
    t.string   "status",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "html_file_id",     limit: 4
    t.integer  "resolved_by",      limit: 4
    t.text     "highlight",        limit: 16777215
    t.integer  "reported_by",      limit: 4
    t.integer  "manifestation_id", limit: 4
  end

  create_table "publications", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "publisher_line", limit: 255
    t.string   "author_line",    limit: 255
    t.text     "notes",          limit: 65535
    t.string   "source_id",      limit: 255
    t.integer  "person_id",      limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "status",         limit: 4
    t.string   "pub_year",       limit: 255
    t.string   "language",       limit: 255
    t.integer  "bib_source_id",  limit: 4
  end

  add_index "publications", ["bib_source_id"], name: "index_publications_on_bib_source_id", using: :btree
  add_index "publications", ["person_id"], name: "index_publications_on_person_id", using: :btree

  create_table "realizers", force: :cascade do |t|
    t.integer  "expression_id", limit: 4
    t.integer  "person_id",     limit: 4
    t.integer  "role",          limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "realizers", ["expression_id"], name: "index_realizers_on_expression_id", using: :btree
  add_index "realizers", ["person_id"], name: "index_realizers_on_person_id", using: :btree

  create_table "recommendations", force: :cascade do |t|
    t.text     "body",             limit: 65535
    t.integer  "user_id",          limit: 4
    t.integer  "approved_by",      limit: 4
    t.integer  "status",           limit: 4
    t.integer  "manifestation_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "recommendations", ["manifestation_id", "status"], name: "index_recommendations_on_manifestation_id_and_status", using: :btree
  add_index "recommendations", ["manifestation_id"], name: "index_recommendations_on_manifestation_id", using: :btree
  add_index "recommendations", ["user_id"], name: "index_recommendations_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,      null: false
    t.text     "data",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "static_pages", force: :cascade do |t|
    t.string   "tag",        limit: 255
    t.string   "title",      limit: 255
    t.text     "body",       limit: 16777215
    t.integer  "status",     limit: 4
    t.integer  "mode",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "ltr"
  end

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
    t.text     "toc",            limit: 16777215
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "credit_section", limit: 65535
    t.integer  "status",         limit: 4
  end

  create_table "user_preferences", force: :cascade do |t|
    t.string  "name",    limit: 255, null: false
    t.string  "value",   limit: 255
    t.integer "user_id", limit: 4,   null: false
  end

  add_index "user_preferences", ["user_id", "name"], name: "index_user_preferences_on_user_id_and_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.string   "provider",            limit: 255
    t.string   "uid",                 limit: 255
    t.string   "oauth_token",         limit: 255
    t.datetime "oauth_expires_at"
    t.boolean  "admin"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "editor"
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
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

  create_table "volunteer_profile_features", force: :cascade do |t|
    t.integer  "volunteer_profile_id", limit: 4
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "volunteer_profile_features", ["volunteer_profile_id"], name: "index_volunteer_profile_features_on_volunteer_profile_id", using: :btree

  create_table "volunteer_profiles", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.text     "bio",                        limit: 65535
    t.text     "about",                      limit: 65535
    t.string   "profile_image_file_name",    limit: 255
    t.string   "profile_image_content_type", limit: 255
    t.integer  "profile_image_file_size",    limit: 4
    t.datetime "profile_image_updated_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "work_likes", id: false, force: :cascade do |t|
    t.integer "manifestation_id", limit: 4, null: false
    t.integer "user_id",          limit: 4, null: false
  end

  add_index "work_likes", ["manifestation_id", "user_id"], name: "index_work_likes_on_manifestation_id_and_user_id", using: :btree
  add_index "work_likes", ["user_id", "manifestation_id"], name: "index_work_likes_on_user_id_and_manifestation_id", using: :btree

  create_table "works", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "form",           limit: 255
    t.string   "date",           limit: 255
    t.text     "comment",        limit: 16777215
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "genre",          limit: 255
    t.string   "orig_lang",      limit: 255
    t.string   "origlang_title", limit: 255
  end

  add_foreign_key "aboutnesses", "users"
  add_foreign_key "aboutnesses", "works"
  add_foreign_key "featured_author_features", "featured_authors"
  add_foreign_key "featured_authors", "people"
  add_foreign_key "featured_authors", "users"
  add_foreign_key "featured_content_features", "featured_contents"
  add_foreign_key "featured_contents", "manifestations"
  add_foreign_key "featured_contents", "people"
  add_foreign_key "featured_contents", "users"
  add_foreign_key "holdings", "publications"
  add_foreign_key "list_items", "users"
  add_foreign_key "publications", "bib_sources"
  add_foreign_key "publications", "people"
  add_foreign_key "realizers", "expressions"
  add_foreign_key "realizers", "people"
  add_foreign_key "recommendations", "manifestations"
  add_foreign_key "recommendations", "users"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "volunteer_profile_features", "volunteer_profiles"
end
