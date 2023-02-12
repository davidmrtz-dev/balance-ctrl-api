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

ActiveRecord::Schema.define(version: 2023_02_12_185218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.text "description"
    t.decimal "current_amount", default: "0.0", null: false
    t.decimal "{:precision=>20, :scale=>2}", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_balances_on_user_id"
  end

  create_table "incomes", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.integer "income_type", null: false
    t.string "title"
    t.string "description"
    t.integer "income_frequency", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_incomes_on_balance_id"
  end

  create_table "outcomes", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.integer "outcome_type", null: false
    t.string "title"
    t.string "description"
    t.datetime "purchase_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_outcomes_on_balance_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "paymentable_type", null: false
    t.bigint "paymentable_id", null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "{:precision=>8, :scale=>2}", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["paymentable_type", "paymentable_id"], name: "index_payments_on_paymentable"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.integer "type", null: false
    t.integer "transaction_type", null: false
    t.string "description"
    t.integer "frequency", null: false
    t.datetime "purchase_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_transactions_on_balance_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "incomes", "balances"
  add_foreign_key "outcomes", "balances"
  add_foreign_key "transactions", "balances"
end
