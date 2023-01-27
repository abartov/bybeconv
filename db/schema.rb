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

ActiveRecord::Schema.define(version: 2023_01_25_225540) do

  create_table "aboutnesses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "work_id"
    t.integer "user_id"
    t.integer "status"
    t.integer "wikidata_qid"
    t.integer "aboutable_id"
    t.string "aboutable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "wikidata_label"
    t.index ["aboutable_type", "aboutable_id"], name: "index_aboutnesses_on_aboutable_type_and_aboutable_id"
    t.index ["user_id"], name: "index_aboutnesses_on_user_id"
    t.index ["wikidata_qid"], name: "index_aboutnesses_on_wikidata_qid"
    t.index ["work_id"], name: "index_aboutnesses_on_work_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", limit: 191, null: false
    t.string "record_type", limit: 191, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "key", limit: 191, null: false
    t.string "filename", limit: 191, null: false
    t.string "content_type", limit: 191
    t.text "metadata", limit: 16777215
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 191, null: false
    t.datetime "created_at", null: false
    t.string "service_name"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "anthologies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.integer "access"
    t.integer "cached_page_count"
    t.text "sequence", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_anthologies_on_user_id"
  end

  create_table "anthology_texts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.text "body", limit: 16777215
    t.bigint "anthology_id"
    t.integer "manifestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cached_page_count"
    t.index ["anthology_id"], name: "index_anthology_texts_on_anthology_id"
    t.index ["manifestation_id"], name: "index_anthology_texts_on_manifestation_id"
  end

  create_table "api_keys", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "email"
    t.string "description"
    t.string "key"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_api_keys_on_email", unique: true
    t.index ["key"], name: "index_api_keys_on_key", unique: true
  end

  create_table "base_user_preferences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "value"
    t.bigint "base_user_id", null: false
    t.index ["base_user_id"], name: "index_base_user_preferences_on_base_user_id"
  end

  create_table "base_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "session_id"
    t.index ["session_id"], name: "index_base_users_on_session_id", unique: true
    t.index ["user_id"], name: "index_base_users_on_user_id", unique: true
  end

  create_table "bib_sources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "source_type"
    t.string "url"
    t.integer "port"
    t.string "api_key"
    t.text "comments", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "institution"
    t.string "item_pattern", limit: 2048
  end

  create_table "blazer_audits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "bookmarks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "manifestation_id"
    t.string "bookmark_p"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "base_user_id", null: false
    t.index ["base_user_id", "manifestation_id"], name: "index_bookmarks_on_base_user_id_and_manifestation_id", unique: true
    t.index ["base_user_id"], name: "index_bookmarks_on_base_user_id"
    t.index ["manifestation_id"], name: "index_bookmarks_on_manifestation_id"
  end

  create_table "creations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "work_id"
    t.integer "person_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_creations_on_person_id"
    t.index ["work_id"], name: "index_creations_on_work_id"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", limit: 16777215, null: false
    t.text "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "dictionary_aliases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "dictionary_entry_id"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dictionary_entry_id"], name: "index_dictionary_aliases_on_dictionary_entry_id"
  end

  create_table "dictionary_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "manifestation_id"
    t.integer "sequential_number"
    t.string "defhead"
    t.text "deftext", limit: 16777215
    t.integer "source_def_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sort_defhead"
    t.index ["defhead"], name: "index_dictionary_entries_on_defhead"
    t.index ["manifestation_id", "sequential_number"], name: "manif_and_seqno_index"
    t.index ["manifestation_id"], name: "index_dictionary_entries_on_manifestation_id"
    t.index ["sequential_number"], name: "index_dictionary_entries_on_sequential_number"
    t.index ["sort_defhead"], name: "index_dictionary_entries_on_sort_defhead"
    t.index ["source_def_id"], name: "index_dictionary_entries_on_source_def_id"
  end

  create_table "dictionary_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "from_entry_id"
    t.bigint "to_entry_id"
    t.integer "linktype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_entry_id"], name: "index_dictionary_links_on_from_entry_id"
    t.index ["to_entry_id"], name: "index_dictionary_links_on_to_entry_id"
  end

  create_table "downloadables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "object_type"
    t.bigint "object_id"
    t.integer "doctype"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_type", "object_id"], name: "index_downloadables_on_object_type_and_object_id"
  end

  create_table "expressions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.string "form"
    t.string "date"
    t.string "language"
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "copyrighted"
    t.date "copyright_expiration"
    t.boolean "translation"
    t.string "source_edition"
    t.integer "period"
    t.string "normalized_pub_date"
    t.string "normalized_creation_date"
    t.integer "work_id", null: false
    t.index ["normalized_creation_date"], name: "index_expressions_on_normalized_creation_date"
    t.index ["normalized_pub_date"], name: "index_expressions_on_normalized_pub_date"
    t.index ["period"], name: "index_expressions_on_period"
    t.index ["work_id"], name: "index_expressions_on_work_id"
  end

  create_table "external_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "url", limit: 2048
    t.integer "linktype"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "linkable_id"
    t.string "linkable_type"
    t.index ["linkable_type", "linkable_id"], name: "index_external_links_on_linkable_type_and_linkable_id"
  end

  create_table "featured_author_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.datetime "fromdate"
    t.datetime "todate"
    t.integer "featured_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured_author_id"], name: "index_featured_author_features_on_featured_author_id"
  end

  create_table "featured_authors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.integer "person_id"
    t.text "body", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_featured_authors_on_person_id"
    t.index ["user_id"], name: "index_featured_authors_on_user_id"
  end

  create_table "featured_content_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "featured_content_id"
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured_content_id"], name: "index_featured_content_features_on_featured_content_id"
  end

  create_table "featured_contents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "manifestation_id"
    t.integer "person_id"
    t.text "body", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_link"
    t.integer "user_id_id"
    t.integer "user_id"
    t.index ["manifestation_id"], name: "index_featured_contents_on_manifestation_id"
    t.index ["person_id"], name: "index_featured_contents_on_person_id"
    t.index ["user_id"], name: "index_featured_contents_on_user_id"
    t.index ["user_id_id"], name: "index_featured_contents_on_user_id_id"
  end

  create_table "holdings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "publication_id"
    t.string "source_id", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "scan_url", limit: 2048
    t.integer "bib_source_id"
    t.string "location"
    t.index ["bib_source_id"], name: "index_holdings_on_bib_source_id"
    t.index ["publication_id"], name: "index_holdings_on_publication_id"
  end

  create_table "html_dirs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "path"
    t.string "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "need_resequence"
    t.boolean "public_domain"
    t.integer "person_id"
    t.index ["person_id"], name: "html_dirs_person_id_fk"
  end

  create_table "html_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "path"
    t.string "url"
    t.string "status"
    t.string "problem"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "tables"
    t.boolean "footnotes"
    t.boolean "images"
    t.string "nikkud"
    t.boolean "line_numbers"
    t.string "indentation"
    t.string "headings"
    t.string "orig_mtime"
    t.string "orig_ctime"
    t.boolean "stripped_nikkud"
    t.string "orig_lang"
    t.string "year_published"
    t.string "orig_year_published"
    t.integer "seqno"
    t.string "orig_author"
    t.string "orig_author_url"
    t.integer "person_id"
    t.string "genre"
    t.boolean "paras_condensed", default: false
    t.integer "translator_id"
    t.integer "assignee_id"
    t.text "comments"
    t.string "title"
    t.string "doc_file_name"
    t.string "doc_content_type"
    t.integer "doc_file_size"
    t.datetime "doc_updated_at"
    t.text "markdown", limit: 4294967295
    t.string "publisher"
    t.string "pub_link"
    t.string "pub_link_text"
    t.index ["assignee_id"], name: "index_html_files_on_assignee_id"
    t.index ["path"], name: "index_html_files_on_path"
    t.index ["person_id"], name: "html_files_person_id_fk"
    t.index ["status"], name: "index_html_files_on_status"
    t.index ["translator_id"], name: "html_files_translator_id_fk"
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
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
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
    t.string "from"
    t.string "about"
    t.string "what"
    t.boolean "subscribe"
    t.string "status"
    t.integer "resolved_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "html_file_id"
    t.integer "recommended_by"
    t.integer "manifestation_id"
    t.index ["html_file_id"], name: "legacy_recommendations_html_file_id_fk"
    t.index ["manifestation_id"], name: "legacy_recommendations_manifestation_id_fk"
    t.index ["recommended_by"], name: "legacy_recommendations_recommended_by_fk"
  end

  create_table "lex_citations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.string "from_publication"
    t.string "authors"
    t.string "pages"
    t.string "link"
    t.string "item_type"
    t.bigint "item_id"
    t.integer "manifestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authors"], name: "index_lex_citations_on_authors"
    t.index ["item_type", "item_id"], name: "index_lex_citations_on_item_type_and_item_id"
    t.index ["manifestation_id"], name: "index_lex_citations_on_manifestation_id"
    t.index ["title"], name: "index_lex_citations_on_title"
  end

  create_table "lex_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lex_item_type"
    t.bigint "lex_item_id"
    t.string "sort_title"
    t.index ["lex_item_type", "lex_item_id"], name: "index_lex_entries_on_lex_item_type_and_lex_item_id", unique: true
    t.index ["sort_title"], name: "index_lex_entries_on_sort_title"
    t.index ["status"], name: "index_lex_entries_on_status"
    t.index ["title"], name: "index_lex_entries_on_title"
  end

  create_table "lex_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "fname"
    t.integer "status"
    t.string "title"
    t.integer "entrytype"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "lex_entry_id"
    t.string "full_path"
    t.index ["entrytype"], name: "index_lex_files_on_entrytype"
    t.index ["fname"], name: "index_lex_files_on_fname"
    t.index ["lex_entry_id"], name: "index_lex_files_on_lex_entry_id", unique: true
    t.index ["status"], name: "index_lex_files_on_status"
  end

  create_table "lex_issues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "subtitle"
    t.string "volume"
    t.string "issue"
    t.integer "seq_num"
    t.text "toc"
    t.bigint "lex_publication_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lex_publication_id"], name: "index_lex_issues_on_lex_publication_id"
    t.index ["seq_num"], name: "index_lex_issues_on_seq_num"
    t.index ["subtitle"], name: "index_lex_issues_on_subtitle"
  end

  create_table "lex_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "url"
    t.string "description"
    t.integer "status"
    t.string "item_type"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_lex_links_on_item_type_and_item_id"
  end

  create_table "lex_people", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "aliases"
    t.boolean "copyrighted"
    t.string "birthdate"
    t.string "deathdate"
    t.text "bio"
    t.text "works"
    t.text "about"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "person_id"
    t.text "translations"
    t.index ["aliases"], name: "index_lex_people_on_aliases"
    t.index ["birthdate"], name: "index_lex_people_on_birthdate"
    t.index ["copyrighted"], name: "index_lex_people_on_copyrighted"
    t.index ["deathdate"], name: "index_lex_people_on_deathdate"
    t.index ["person_id"], name: "index_lex_people_on_person_id"
  end

  create_table "lex_people_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "lex_person_id"
    t.string "item_type"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_lex_people_items_on_item_type_and_item_id"
    t.index ["lex_person_id"], name: "index_lex_people_items_on_lex_person_id"
  end

  create_table "lex_publications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "description"
    t.text "toc"
    t.boolean "az_navbar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lex_texts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.string "authors"
    t.string "pages"
    t.bigint "lex_publication_id"
    t.bigint "lex_issue_id"
    t.integer "manifestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lex_issue_id"], name: "index_lex_texts_on_lex_issue_id"
    t.index ["lex_publication_id"], name: "index_lex_texts_on_lex_publication_id"
    t.index ["manifestation_id"], name: "index_lex_texts_on_manifestation_id"
    t.index ["title"], name: "index_lex_texts_on_title"
  end

  create_table "list_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "listkey"
    t.integer "item_id"
    t.string "item_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_list_items_on_item_type_and_item_id"
    t.index ["listkey", "item_id"], name: "index_list_items_on_listkey_and_item_id"
    t.index ["listkey", "user_id", "item_id"], name: "index_list_items_on_listkey_and_user_id_and_item_id"
    t.index ["listkey"], name: "index_list_items_on_listkey"
    t.index ["user_id"], name: "index_list_items_on_user_id"
  end

  create_table "manifestations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.string "responsibility_statement"
    t.string "edition"
    t.string "identifier"
    t.string "medium"
    t.string "publisher"
    t.string "publication_place"
    t.string "publication_date"
    t.string "series_statement"
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "markdown", limit: 16777215
    t.text "cached_people"
    t.integer "impressions_count"
    t.text "cached_heading_lines"
    t.boolean "conversion_verified"
    t.integer "conv_counter"
    t.integer "status"
    t.string "sort_title"
    t.boolean "sefaria_linker"
    t.integer "expression_id", null: false
    t.string "alternate_titles", limit: 512
    t.index ["conv_counter"], name: "index_manifestations_on_conv_counter"
    t.index ["created_at"], name: "index_manifestations_on_created_at"
    t.index ["expression_id"], name: "index_manifestations_on_expression_id"
    t.index ["impressions_count"], name: "index_manifestations_on_impressions_count"
    t.index ["sort_title"], name: "index_manifestations_on_sort_title"
    t.index ["status", "sort_title"], name: "index_manifestations_on_status_and_sort_title"
    t.index ["status"], name: "index_manifestations_on_status"
  end

  create_table "news_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "itemtype"
    t.string "title"
    t.boolean "pinned"
    t.datetime "relevance"
    t.string "body"
    t.string "url"
    t.boolean "double"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "thumbnail_url"
    t.index ["relevance"], name: "index_news_items_on_relevance"
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "dates"
    t.string "title"
    t.string "other_designation", limit: 1024
    t.string "affiliation"
    t.string "country"
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "viaf_id"
    t.string "nli_id"
    t.integer "toc_id"
    t.boolean "public_domain"
    t.text "wikipedia_snippet", limit: 16777215
    t.string "wikipedia_url", limit: 1024
    t.string "image_url", limit: 1024
    t.string "profile_image_file_name"
    t.string "profile_image_content_type"
    t.integer "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.integer "wikidata_id"
    t.string "birthdate"
    t.string "deathdate"
    t.boolean "metadata_approved", default: false
    t.integer "gender"
    t.integer "impressions_count"
    t.string "blog_category_url"
    t.boolean "bib_done"
    t.integer "period"
    t.string "sidepic_file_name"
    t.string "sidepic_content_type"
    t.bigint "sidepic_file_size"
    t.datetime "sidepic_updated_at"
    t.string "sort_name"
    t.integer "status"
    t.datetime "published_at"
    t.index ["gender"], name: "gender_index"
    t.index ["id"], name: "tstid"
    t.index ["impressions_count"], name: "index_people_on_impressions_count"
    t.index ["name"], name: "index_people_on_name"
    t.index ["period"], name: "index_people_on_period"
    t.index ["sort_name"], name: "index_people_on_sort_name"
    t.index ["status", "published_at"], name: "index_people_on_status_and_published_at"
    t.index ["toc_id"], name: "people_toc_id_fk"
  end

  create_table "periods", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.text "comments", limit: 16777215
    t.string "wikipedia_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proofs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "from"
    t.string "about"
    t.text "what", limit: 16777215
    t.boolean "subscribe"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "html_file_id"
    t.integer "resolved_by"
    t.text "highlight", limit: 16777215
    t.integer "reported_by"
    t.integer "manifestation_id"
    t.index ["html_file_id"], name: "proofs_html_file_id_fk"
    t.index ["manifestation_id"], name: "proofs_manifestation_id_fk"
    t.index ["resolved_by"], name: "proofs_resolved_by_fk"
  end

  create_table "publications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title", limit: 1024
    t.string "publisher_line"
    t.string "author_line", limit: 1024
    t.text "notes", limit: 16777215
    t.string "source_id", limit: 1024
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "pub_year"
    t.string "language"
    t.integer "bib_source_id"
    t.integer "task_id"
    t.index ["bib_source_id"], name: "index_publications_on_bib_source_id"
    t.index ["person_id"], name: "index_publications_on_person_id"
    t.index ["task_id"], name: "index_publications_on_task_id"
  end

  create_table "reading_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.integer "access"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reading_lists_on_user_id"
  end

  create_table "realizers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "expression_id"
    t.integer "person_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expression_id"], name: "index_realizers_on_expression_id"
    t.index ["person_id"], name: "index_realizers_on_person_id"
    t.index ["role", "person_id"], name: "index_realizers_on_role_and_person_id"
  end

  create_table "recommendations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "body", limit: 16777215
    t.integer "user_id"
    t.integer "approved_by"
    t.integer "status"
    t.integer "manifestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by"], name: "recommendations_approved_by_fk"
    t.index ["manifestation_id", "status"], name: "index_recommendations_on_manifestation_id_and_status"
    t.index ["manifestation_id"], name: "index_recommendations_on_manifestation_id"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sitenotices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "body", limit: 16777215
    t.datetime "fromdate"
    t.datetime "todate"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fromdate"], name: "index_sitenotices_on_fromdate"
    t.index ["status"], name: "index_sitenotices_on_status"
    t.index ["todate"], name: "index_sitenotices_on_todate"
  end

  create_table "sitenotices_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "sitenotice_id", null: false
    t.bigint "user_id", null: false
    t.string "session_id"
    t.boolean "suppress"
    t.index ["session_id"], name: "index_sitenotices_users_on_session_id"
  end

  create_table "static_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "tag"
    t.string "title"
    t.text "body", limit: 16777215, collation: "utf8mb3_bin"
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
    t.index ["approved_by"], name: "taggings_approved_by_fk"
    t.index ["manifestation_id"], name: "taggings_manifestation_id_fk"
    t.index ["suggested_by"], name: "taggings_suggested_by_fk"
    t.index ["tag_id"], name: "taggings_tag_id_fk"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "tags_created_by_fk"
  end

  create_table "tocs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "toc", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "credit_section"
    t.integer "status"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editor"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "tasks_api_key"
  end

  create_table "versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "volunteer_profile_features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "volunteer_profile_id"
    t.datetime "fromdate"
    t.datetime "todate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_profile_id"], name: "index_volunteer_profile_features_on_volunteer_profile_id"
  end

  create_table "volunteer_profiles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.text "bio", limit: 16777215
    t.text "about", limit: 16777215
    t.string "profile_image_file_name"
    t.string "profile_image_content_type"
    t.integer "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_likes", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "manifestation_id", null: false
    t.integer "user_id", null: false
    t.index ["manifestation_id", "user_id"], name: "index_work_likes_on_manifestation_id_and_user_id"
    t.index ["user_id", "manifestation_id"], name: "index_work_likes_on_user_id_and_manifestation_id"
  end

  create_table "works", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.string "form"
    t.string "date"
    t.text "comment", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre"
    t.string "orig_lang"
    t.string "origlang_title"
    t.string "normalized_pub_date"
    t.string "normalized_creation_date"
    t.index ["normalized_creation_date"], name: "index_works_on_normalized_creation_date"
    t.index ["normalized_pub_date"], name: "index_works_on_normalized_pub_date"
  end

  add_foreign_key "aboutnesses", "users", name: "aboutnesses_user_id_fk"
  add_foreign_key "aboutnesses", "works", name: "aboutnesses_work_id_fk"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "anthologies", "users"
  add_foreign_key "anthology_texts", "anthologies"
  add_foreign_key "anthology_texts", "manifestations"
  add_foreign_key "base_user_preferences", "base_users"
  add_foreign_key "base_users", "users"
  add_foreign_key "bookmarks", "base_users"
  add_foreign_key "bookmarks", "manifestations"
  add_foreign_key "creations", "people", name: "creations_person_id_fk"
  add_foreign_key "creations", "works", name: "creations_work_id_fk"
  add_foreign_key "dictionary_aliases", "dictionary_entries"
  add_foreign_key "dictionary_entries", "manifestations"
  add_foreign_key "dictionary_links", "dictionary_entries", column: "from_entry_id"
  add_foreign_key "dictionary_links", "dictionary_entries", column: "to_entry_id"
  add_foreign_key "expressions", "works"
  add_foreign_key "featured_author_features", "featured_authors"
  add_foreign_key "featured_authors", "people"
  add_foreign_key "featured_authors", "users"
  add_foreign_key "featured_content_features", "featured_contents"
  add_foreign_key "featured_contents", "manifestations"
  add_foreign_key "featured_contents", "people"
  add_foreign_key "featured_contents", "users"
  add_foreign_key "holdings", "bib_sources"
  add_foreign_key "holdings", "publications"
  add_foreign_key "html_dirs", "people", name: "html_dirs_person_id_fk"
  add_foreign_key "html_files", "people", column: "translator_id", name: "html_files_translator_id_fk"
  add_foreign_key "html_files", "people", name: "html_files_person_id_fk"
  add_foreign_key "html_files", "users", column: "assignee_id", name: "html_files_assignee_id_fk"
  add_foreign_key "html_files_manifestations", "html_files", name: "html_files_manifestations_html_file_id_fk"
  add_foreign_key "html_files_manifestations", "manifestations", name: "html_files_manifestations_manifestation_id_fk"
  add_foreign_key "legacy_recommendations", "html_files", name: "legacy_recommendations_html_file_id_fk"
  add_foreign_key "legacy_recommendations", "manifestations", name: "legacy_recommendations_manifestation_id_fk"
  add_foreign_key "legacy_recommendations", "users", column: "recommended_by", name: "legacy_recommendations_recommended_by_fk"
  add_foreign_key "lex_citations", "manifestations"
  add_foreign_key "lex_files", "lex_entries"
  add_foreign_key "lex_issues", "lex_publications"
  add_foreign_key "lex_people", "people"
  add_foreign_key "lex_people_items", "lex_people"
  add_foreign_key "lex_texts", "lex_issues"
  add_foreign_key "lex_texts", "lex_publications"
  add_foreign_key "lex_texts", "manifestations"
  add_foreign_key "list_items", "users"
  add_foreign_key "manifestations", "expressions"
  add_foreign_key "people", "tocs", name: "people_toc_id_fk"
  add_foreign_key "proofs", "html_files", name: "proofs_html_file_id_fk"
  add_foreign_key "proofs", "manifestations", name: "proofs_manifestation_id_fk"
  add_foreign_key "proofs", "users", column: "resolved_by", name: "proofs_resolved_by_fk"
  add_foreign_key "publications", "bib_sources"
  add_foreign_key "publications", "people"
  add_foreign_key "reading_lists", "users"
  add_foreign_key "realizers", "expressions"
  add_foreign_key "realizers", "people"
  add_foreign_key "recommendations", "manifestations"
  add_foreign_key "recommendations", "users"
  add_foreign_key "recommendations", "users", column: "approved_by", name: "recommendations_approved_by_fk"
  add_foreign_key "taggings", "manifestations", name: "taggings_manifestation_id_fk"
  add_foreign_key "taggings", "tags", name: "taggings_tag_id_fk"
  add_foreign_key "taggings", "users", column: "approved_by", name: "taggings_approved_by_fk"
  add_foreign_key "taggings", "users", column: "suggested_by", name: "taggings_suggested_by_fk"
  add_foreign_key "tags", "users", column: "created_by", name: "tags_created_by_fk"
  add_foreign_key "volunteer_profile_features", "volunteer_profiles"
  add_foreign_key "work_likes", "manifestations", name: "work_likes_manifestation_id_fk"
  add_foreign_key "work_likes", "users", name: "work_likes_user_id_fk"
end
