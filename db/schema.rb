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

ActiveRecord::Schema[7.1].define(version: 2024_11_06_193356) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "casilleros", force: :cascade do |t|
    t.boolean "apertura"
    t.string "clave"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.bigint "controlador_id", null: false
    t.bigint "metricas_id", null: false
    t.index ["controlador_id"], name: "index_casilleros_on_controlador_id"
    t.index ["metricas_id"], name: "index_casilleros_on_metricas_id"
    t.index ["usuario_id"], name: "index_casilleros_on_usuario_id"
  end

  create_table "controladors", force: :cascade do |t|
    t.string "nombre"
    t.boolean "casilleros_activos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "modelo_id", null: false
    t.bigint "usuario_id", null: false
    t.index ["modelo_id"], name: "index_controladors_on_modelo_id"
    t.index ["usuario_id"], name: "index_controladors_on_usuario_id"
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

  create_table "usuarios", force: :cascade do |t|
    t.string "mail"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.boolean "super_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "modelo_id", null: false
    t.index ["modelo_id"], name: "index_usuarios_on_modelo_id"
  end

  add_foreign_key "casilleros", "controladors"
  add_foreign_key "casilleros", "metricas", column: "metricas_id"
  add_foreign_key "casilleros", "usuarios"
  add_foreign_key "controladors", "modelos"
  add_foreign_key "controladors", "usuarios"
  add_foreign_key "usuarios", "modelos"
end
