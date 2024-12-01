# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_01_211725) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "lockers", force: :cascade do |t|
    t.boolean "opening"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "manager_id"
    t.bigint "metric_id", null: false
    t.string "name"
    t.index ["manager_id"], name: "index_lockers_on_manager_id"
    t.index ["metric_id"], name: "index_lockers_on_metric_id"
    t.index ["user_id"], name: "index_lockers_on_user_id"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "predictor_id"
    t.bigint "user_id", null: false
    t.string "mac_address"
    t.index ["predictor_id"], name: "index_managers_on_predictor_id"
    t.index ["user_id"], name: "index_managers_on_user_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.integer "openings_count"
    t.integer "failed_attempts_count"
    t.integer "password_changes_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "openings", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.datetime "opened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "closed_at"
    t.index ["locker_id"], name: "index_openings_on_locker_id"
  end

  create_table "predictors", force: :cascade do |t|
    t.string "sign1"
    t.string "sign2"
    t.string "sign3"
    t.string "sign4"
    t.string "sign5"
    t.string "sign6"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "signs", force: :cascade do |t|
    t.string "sign_name"
    t.bigint "predictor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["predictor_id"], name: "index_signs_on_predictor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "mail"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.boolean "super_user", default: false, null: false
    t.string "full_name"
    t.string "uid"
    t.string "provider"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "predictor_id"
    t.string "password_digest"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["predictor_id"], name: "index_users_on_predictor_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "lockers", "lockers", column: "manager_id"
  add_foreign_key "lockers", "metrics"
  add_foreign_key "lockers", "users"
  add_foreign_key "managers", "predictors"
  add_foreign_key "managers", "users"
  add_foreign_key "openings", "lockers"
  add_foreign_key "signs", "predictors"
  add_foreign_key "users", "predictors"
end
