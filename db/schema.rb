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

ActiveRecord::Schema.define(version: 2024_02_17_021128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "balance_payments", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_balance_payments_on_balance_id"
    t.index ["payment_id"], name: "index_balance_payments_on_payment_id"
  end

  create_table "balances", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.text "description"
    t.decimal "current_amount", precision: 20, scale: 2, default: "0.0", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_balances_on_user_id"
  end

  create_table "billing_transactions", force: :cascade do |t|
    t.bigint "billing_id", null: false
    t.bigint "transaction_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["billing_id", "transaction_id"], name: "unique_billing_transaction", unique: true
    t.index ["billing_id"], name: "index_billing_transactions_on_billing_id"
    t.index ["transaction_id"], name: "index_billing_transactions_on_transaction_id"
  end

  create_table "billings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.date "cycle_end_date"
    t.date "payment_due_date"
    t.integer "billing_type", null: false
    t.datetime "discarded_at"
    t.string "encrypted_credit_card_number"
    t.string "encrypted_credit_card_number_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discarded_at"], name: "index_billings_on_discarded_at"
    t.index ["encrypted_credit_card_number_iv"], name: "index_billings_on_encrypted_credit_card_number_iv"
    t.index ["user_id"], name: "index_billings_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_categories_on_discarded_at"
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["transaction_id"], name: "index_categorizations_on_transaction_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.string "paymentable_type", null: false
    t.bigint "paymentable_id", null: false
    t.uuid "folio", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "amount", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "refund_id"
    t.datetime "paid_at"
    t.index ["paymentable_type", "paymentable_id"], name: "index_payments_on_paymentable"
    t.index ["refund_id"], name: "index_payments_on_refund_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.string "type", null: false
    t.integer "transaction_type", null: false
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.string "description"
    t.integer "frequency"
    t.datetime "transaction_date"
    t.integer "quotas"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["balance_id"], name: "index_transactions_on_balance_id"
    t.index ["discarded_at"], name: "index_transactions_on_discarded_at"
    t.index ["type"], name: "index_transactions_on_type"
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

  add_foreign_key "balance_payments", "balances"
  add_foreign_key "balance_payments", "payments"
  add_foreign_key "billing_transactions", "billings"
  add_foreign_key "billing_transactions", "transactions"
  add_foreign_key "billings", "users"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "transactions"
  add_foreign_key "payments", "payments", column: "refund_id"
  add_foreign_key "transactions", "balances"
end
