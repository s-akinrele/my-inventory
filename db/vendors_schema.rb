# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use bin/rails db:schema:load, or
# bin/rails db:schema:dump to regenerate this file.

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000000) do
  create_table "vendors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "address"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_vendors_on_email", unique: true
  end
end
