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

ActiveRecord::Schema[7.1].define(version: 2024_11_09_142957) do
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

  create_table "casilleros", force: :cascade do |t|
    t.boolean "apertura"
    t.string "clave"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.bigint "controlador_id", null: false
    t.bigint "metrica_id", null: false
    t.index ["controlador_id"], name: "index_casilleros_on_controlador_id"
    t.index ["metrica_id"], name: "index_casilleros_on_metrica_id"
    t.index ["usuario_id"], name: "index_casilleros_on_usuario_id"
  end

  create_table "controladores", force: :cascade do |t|
    t.string "nombre"
    t.boolean "casilleros_activos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "modelo_id", null: false
    t.bigint "usuario_id", null: false
    t.index ["modelo_id"], name: "index_controladores_on_modelo_id"
    t.index ["usuario_id"], name: "index_controladores_on_usuario_id"
  end

  create_table "metricas", force: :cascade do |t|
    t.integer "cant_aperturas"
    t.integer "cant_intentos_fallidos"
    t.integer "cant_cambios_contrasena"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "modelos", force: :cascade do |t|
    t.string "sign1"
    t.string "sign2"
    t.string "sign3"
    t.string "sign4"
    t.string "sign5"
    t.string "sign6"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signs", force: :cascade do |t|
    t.string "sign_name"
    t.bigint "modelo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modelo_id"], name: "index_signs_on_modelo_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "mail"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.boolean "super_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "modelo_id", null: false
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
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["modelo_id"], name: "index_usuarios_on_modelo_id"
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "casilleros", "controladores"
  add_foreign_key "casilleros", "metricas"
  add_foreign_key "casilleros", "usuarios"
  add_foreign_key "controladores", "modelos"
  add_foreign_key "controladores", "usuarios"
  add_foreign_key "signs", "modelos"
  add_foreign_key "usuarios", "modelos"
end
