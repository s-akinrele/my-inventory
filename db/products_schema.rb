# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use bin/rails db:schema:load, or
# bin/rails db:schema:dump to regenerate this file.

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000001) do
  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "vendor_id", null: false
    t.string "sku", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end
end
