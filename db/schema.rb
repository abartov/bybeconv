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

ActiveRecord::Schema.define(version: 2018_09_22_122928) do

  create_table "aboutnesses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "work_id"
    t.integer "user_id"
    t.integer "status"
    t.integer "wikidata_qid"
    t.integer "aboutable_id"
    t.string "aboutable_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "wikidata_label", limit: 255
    t.index ["aboutable_type", "aboutable_id"], name: "index_aboutnesses_on_aboutable_type_and_aboutable_id"
    t.index ["user_id"], name: "index_aboutnesses_on_user_id"
    t.index ["wikidata_qid"], name: "index_aboutnesses_on_wikidata_qid"
    t.index ["work_id"], name: "index_aboutnesses_on_work_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "api_keys", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "email", limit: 255
    t.string "description", limit: 255
    t.string "key", limit: 255
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_api_keys_on_email", unique: true
  end

  create_table "bib_sources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.integer "source_type"
    t.string "url", limit: 255
    t.integer "port"
    t.string "api_key", limit: 255
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "institution", limit: 255
    t.string "item_pattern", limit: 2048
  end

  create_table "creations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "work_id"
    t.integer "person_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_creations_on_person_id"
    t.index ["work_id"], name: "index_creations_on_work_id"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "expressions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.string "form", limit: 255
    t.string "date", limit: 255
    t.string "language", limit: 255
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "copyrighted"
    t.date "copyright_expiration"
    t.string "genre", limit: 255
    t.boolean "translation"
    t.string "source_edition", limit: 255
  end

  create_table "expressions_manifestations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "expression_id"
    t.integer "manifestation_id"
    t.index ["expression_id"], name: "index_expressions_manifestations_on_expression_id"
    t.index ["manifestation_id"], name: "index_expressions_manifestations_on_manifestation_id"
  end

  create_table "expressions_works", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "expression_id"
    t.integer "work_id"
    t.index ["expression_id"], name: "index_expressions_works_on_expression_id"
    t.index ["work_id"], name: "index_expressions_works_on_work_id"
  end

  create_table "external_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "url", limit: 255
    t.integer "linktype"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manifestation_id"
    t.string "description", limit: 255
  end

  create_table "featured_author_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.datetime "fromdate"
    t.datetime "todate"
    t.integer "featured_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured_author_id"], name: "index_featured_author_features_on_featured_author_id"
  end

  create_table "featured_authors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.integer "user_id"
    t.integer "person_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_featured_authors_on_person_id"
    t.index ["user_id"], name: "index_featured_authors_on_user_id"
  end

  create_table "featured_content_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "featured_content_id"
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured_content_id"], name: "index_featured_content_features_on_featured_content_id"
  end

  create_table "featured_contents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.integer "manifestation_id"
    t.integer "person_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_link", limit: 255
    t.integer "user_id_id"
    t.integer "user_id"
    t.index ["manifestation_id"], name: "index_featured_contents_on_manifestation_id"
    t.index ["person_id"], name: "index_featured_contents_on_person_id"
    t.index ["user_id"], name: "index_featured_contents_on_user_id"
    t.index ["user_id_id"], name: "index_featured_contents_on_user_id_id"
  end

  create_table "holdings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "publication_id"
    t.string "source_id", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "scan_url", limit: 2048
    t.integer "bib_source_id"
    t.string "location", limit: 255
    t.index ["bib_source_id"], name: "index_holdings_on_bib_source_id"
    t.index ["publication_id"], name: "index_holdings_on_publication_id"
  end

  create_table "html_dirs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "path", limit: 255
    t.string "author", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "need_resequence"
    t.boolean "public_domain"
    t.integer "person_id"
  end

  create_table "html_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "path", limit: 255
    t.string "url", limit: 255
    t.string "status", limit: 255
    t.string "problem", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "tables"
    t.boolean "footnotes"
    t.boolean "images"
    t.string "nikkud", limit: 255
    t.boolean "line_numbers"
    t.string "indentation", limit: 255
    t.string "headings", limit: 255
    t.string "orig_mtime", limit: 255
    t.string "orig_ctime", limit: 255
    t.boolean "stripped_nikkud"
    t.string "orig_lang", limit: 255
    t.string "year_published", limit: 255
    t.string "orig_year_published", limit: 255
    t.integer "seqno"
    t.string "orig_author", limit: 255
    t.string "orig_author_url", limit: 255
    t.integer "person_id"
    t.string "genre", limit: 255
    t.boolean "paras_condensed", default: false
    t.integer "translator_id"
    t.integer "assignee_id"
    t.text "comments"
    t.string "title", limit: 255
    t.string "doc_file_name", limit: 255
    t.string "doc_content_type", limit: 255
    t.integer "doc_file_size"
    t.datetime "doc_updated_at"
    t.text "markdown", limit: 4294967295
    t.string "publisher", limit: 255
    t.index ["assignee_id"], name: "index_html_files_on_assignee_id"
    t.index ["path"], name: "index_html_files_on_path"
    t.index ["url"], name: "index_html_files_on_url"
  end

  create_table "html_files_manifestations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "html_file_id"
    t.integer "manifestation_id"
    t.index ["html_file_id"], name: "index_html_files_manifestations_on_html_file_id"
    t.index ["manifestation_id"], name: "index_html_files_manifestations_on_manifestation_id"
  end

  create_table "impressions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "impressionable_type", limit: 255
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name", limit: 255
    t.string "action_name", limit: 255
    t.string "view_name", limit: 255
    t.string "request_hash", limit: 255
    t.string "ip_address", limit: 255
    t.string "session_hash", limit: 255
    t.text "message", limit: 16777215
    t.text "referrer", limit: 16777215
    t.text "params", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { params: 255 }
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { message: 255 }
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "legacy_recommendations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "from", limit: 255
    t.string "about", limit: 255
    t.string "what", limit: 255
    t.boolean "subscribe"
    t.string "status", limit: 255
    t.integer "resolved_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "html_file_id"
    t.integer "recommended_by"
    t.integer "manifestation_id"
  end

  create_table "list_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "listkey", limit: 255
    t.integer "item_id"
    t.string "item_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_list_items_on_item_type_and_item_id"
    t.index ["listkey", "item_id"], name: "index_list_items_on_listkey_and_item_id"
    t.index ["listkey", "user_id", "item_id"], name: "index_list_items_on_listkey_and_user_id_and_item_id"
    t.index ["listkey"], name: "index_list_items_on_listkey"
    t.index ["user_id"], name: "index_list_items_on_user_id"
  end

  create_table "manifestations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.string "responsibility_statement", limit: 255
    t.string "edition", limit: 255
    t.string "identifier", limit: 255
    t.string "medium", limit: 255
    t.string "publisher", limit: 255
    t.string "publication_place", limit: 255
    t.string "publication_date", limit: 255
    t.string "series_statement", limit: 255
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "markdown", limit: 16777215
    t.string "cached_people", limit: 255
    t.integer "impressions_count"
    t.text "cached_heading_lines"
    t.boolean "conversion_verified"
    t.integer "conv_counter"
    t.integer "status"
    t.index ["conv_counter"], name: "index_manifestations_on_conv_counter"
    t.index ["created_at"], name: "index_manifestations_on_created_at"
    t.index ["impressions_count"], name: "index_manifestations_on_impressions_count"
  end

  create_table "manifestations_people", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manifestation_id"
    t.integer "person_id"
    t.index ["manifestation_id"], name: "index_manifestations_people_on_manifestation_id"
    t.index ["person_id"], name: "index_manifestations_people_on_person_id"
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "dates", limit: 255
    t.string "title", limit: 255
    t.string "other_designation", limit: 1024
    t.string "affiliation", limit: 255
    t.string "country", limit: 255
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "viaf_id", limit: 255
    t.string "nli_id", limit: 255
    t.integer "toc_id"
    t.boolean "public_domain"
    t.integer "period_id"
    t.text "wikipedia_snippet", limit: 16777215
    t.string "wikipedia_url", limit: 1024
    t.string "image_url", limit: 1024
    t.string "profile_image_file_name", limit: 255
    t.string "profile_image_content_type", limit: 255
    t.integer "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.integer "wikidata_id"
    t.string "birthdate", limit: 255
    t.string "deathdate", limit: 255
    t.boolean "metadata_approved", default: false
    t.integer "gender"
    t.integer "impressions_count"
    t.string "blog_category_url", limit: 255
    t.boolean "bib_done"
    t.index ["impressions_count"], name: "index_people_on_impressions_count"
  end

  create_table "periods", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "comments", limit: 16777215
    t.string "wikipedia_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proofs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "from", limit: 255
    t.string "about", limit: 255
    t.text "what", limit: 16777215
    t.boolean "subscribe"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "html_file_id"
    t.integer "resolved_by"
    t.text "highlight", limit: 16777215
    t.integer "reported_by"
    t.integer "manifestation_id"
  end

  create_table "publications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", limit: 1024
    t.string "publisher_line", limit: 255
    t.string "author_line", limit: 1024
    t.text "notes"
    t.string "source_id", limit: 1024
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "pub_year", limit: 255
    t.string "language", limit: 255
    t.integer "bib_source_id"
    t.index ["bib_source_id"], name: "index_publications_on_bib_source_id"
    t.index ["person_id"], name: "index_publications_on_person_id"
  end

  create_table "realizers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "expression_id"
    t.integer "person_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expression_id"], name: "index_realizers_on_expression_id"
    t.index ["person_id"], name: "index_realizers_on_person_id"
  end

  create_table "recommendations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
    t.integer "approved_by"
    t.integer "status"
    t.integer "manifestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manifestation_id", "status"], name: "index_recommendations_on_manifestation_id_and_status"
    t.index ["manifestation_id"], name: "index_recommendations_on_manifestation_id"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "static_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "tag", limit: 255
    t.string "title", limit: 255
    t.text "body", limit: 16777215
    t.integer "status"
    t.integer "mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ltr"
  end

  create_table "taggings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "manifestation_id"
    t.integer "status"
    t.integer "suggested_by"
    t.integer "approved_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "status"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_strings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "field1"
    t.string "field2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tocs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "toc", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "credit_section"
    t.integer "status"
  end

  create_table "user_preferences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "value", limit: 255
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_user_preferences_on_user_id_and_name", unique: true
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "oauth_token", limit: 255
    t.datetime "oauth_expires_at"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editor"
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "volunteer_profile_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "volunteer_profile_id"
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_profile_id"], name: "index_volunteer_profile_features_on_volunteer_profile_id"
  end

  create_table "volunteer_profiles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "bio"
    t.text "about"
    t.string "profile_image_file_name", limit: 255
    t.string "profile_image_content_type", limit: 255
    t.integer "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_likes", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "manifestation_id", null: false
    t.integer "user_id", null: false
    t.index ["manifestation_id", "user_id"], name: "index_work_likes_on_manifestation_id_and_user_id"
    t.index ["user_id", "manifestation_id"], name: "index_work_likes_on_user_id_and_manifestation_id"
  end

  create_table "works", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title", limit: 255
    t.string "form", limit: 255
    t.string "date", limit: 255
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre", limit: 255
    t.string "orig_lang", limit: 255
    t.string "origlang_title", limit: 255
  end

  add_foreign_key "featured_author_features", "featured_authors"
  add_foreign_key "featured_authors", "people"
  add_foreign_key "featured_authors", "users"
  add_foreign_key "featured_content_features", "featured_contents"
  add_foreign_key "featured_contents", "manifestations"
  add_foreign_key "featured_contents", "people"
  add_foreign_key "featured_contents", "users"
  add_foreign_key "holdings", "bib_sources"
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
