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

ActiveRecord::Schema[8.1].define(version: 2026_02_05_095633) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "entity_id", null: false
    t.string "entity_type", null: false
    t.string "event_type", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_audit_logs_on_entity_type_and_entity_id"
    t.index ["event_type"], name: "index_audit_logs_on_event_type"
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.datetime "first_seen_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "device_id"], name: "index_devices_on_user_id_and_device_id", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "fraud_evaluations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_accurate"
    t.integer "risk_score", null: false
    t.text "rules_triggered"
    t.uuid "transaction_id", null: false
    t.datetime "updated_at", null: false
    t.text "user_feedback"
    t.index ["is_accurate"], name: "index_fraud_evaluations_on_is_accurate"
    t.index ["transaction_id"], name: "index_fraud_evaluations_on_transaction_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "device_id"
    t.string "ip_address"
    t.string "payment_method", default: "card"
    t.integer "risk_score", default: 0
    t.string "status", default: "PENDING", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["payment_method"], name: "index_transactions_on_payment_method"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_transaction_stats", force: :cascade do |t|
    t.decimal "avg_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "last_updated_at"
    t.decimal "total_amount", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "total_txns", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_transaction_stats_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "devices", "users"
  add_foreign_key "fraud_evaluations", "transactions"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_transaction_stats", "users"
end
