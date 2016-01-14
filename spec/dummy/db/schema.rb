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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160114013617) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dummy_model_without_encryptions", force: true do |t|
    t.string   "name"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dummy_models", force: true do |t|
    t.integer  "encryption_key_id"
    t.binary   "encrypted_store"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unencrypted_value"
  end

  create_table "encryption_key_salts", force: true do |t|
    t.integer  "encryption_key_id"
    t.binary   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "encryption_key_salts", ["encryption_key_id", "salt"], name: "index_encryption_key_salts_on_encryption_key_id_and_salt", unique: true, using: :btree

  create_table "encryption_keys", force: true do |t|
    t.binary   "dek"
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "encryption_keys", ["created_at"], name: "index_encryption_keys_on_created_at", using: :btree

end
