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

ActiveRecord::Schema.define(version: 2020_05_10_144933) do

  create_table "committees", force: :cascade do |t|
    t.string "fec_id"
    t.string "name"
    t.string "designation_full"
    t.string "alt_name"
    t.datetime "last_file_date"
    t.integer "num_records_available"
    t.integer "num_records_downloaded"
    t.string "last_index"
    t.string "last_date"
    t.string "cycles_active"
    t.datetime "first_file_date"
  end

  create_table "committees_politicians", id: false, force: :cascade do |t|
    t.integer "politician_id", null: false
    t.integer "committee_id", null: false
  end

  create_table "donations", force: :cascade do |t|
    t.integer "donor_id"
    t.integer "committee_id"
    t.integer "amount"
    t.datetime "date"
  end

  create_table "donors", force: :cascade do |t|
    t.string "name"
    t.string "occupation"
    t.string "street_1"
    t.string "street_2"
    t.integer "zip"
    t.string "city"
    t.string "state"
    t.string "employer"
    t.string "line_number"
  end

  create_table "politicians", force: :cascade do |t|
    t.string "name"
    t.string "twitter"
    t.string "domain"
    t.string "party"
    t.string "title"
    t.string "candidate_id"
    t.string "facebook"
    t.string "instagram"
    t.string "youtube"
  end

  create_table "politicians_users", id: false, force: :cascade do |t|
    t.integer "politician_id", null: false
    t.integer "user_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address"
    t.string "zip_code"
    t.string "password"
  end

end
