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

ActiveRecord::Schema.define(version: 20130422133314) do

  create_table "stores", force: true do |t|
    t.string  "domain"
    t.string  "user"
    t.string  "pass"
    t.string  "km_api_key"
    t.integer "last_order_received_id"
    t.integer "last_order_confirmed_id"
    t.integer "last_order_canceled_id"
  end

  add_index "stores", ["domain"], name: "index_stores_on_domain", unique: true

end
