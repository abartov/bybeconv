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

ActiveRecord::Schema.define(:version => 20120409045525) do

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
  end

  add_index "html_files", ["path"], :name => "index_html_files_on_path"

end
