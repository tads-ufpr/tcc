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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_164015) do
  create_table "apartments", force: :cascade do |t|
    t.integer "condominium_id", null: false
    t.integer "floor", null: false
    t.string "number", null: false
    t.string "tower"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominium_id"], name: "index_apartments_on_condominium_id"
  end

  create_table "condominia", force: :cascade do |t|
    t.string "name"
    t.string "zipcode"
    t.string "address"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "city"], name: "index_condominia_on_name_and_city", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "condominium_id", null: false
    t.string "role", default: "normal", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominium_id"], name: "index_employees_on_condominium_id"
    t.index ["user_id", "condominium_id"], name: "index_employees_on_user_id_and_condominium_id", unique: true
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "residents", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "apartment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apartment_id"], name: "index_residents_on_apartment_id"
    t.index ["user_id"], name: "index_residents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "document", limit: 11, null: false
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "phone"
    t.index ["document"], name: "index_users_on_document", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "apartments", "condominia"
  add_foreign_key "employees", "condominia"
  add_foreign_key "employees", "users"
  add_foreign_key "residents", "apartments"
  add_foreign_key "residents", "users"
end
