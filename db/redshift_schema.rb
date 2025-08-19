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

ActiveRecord::Schema.define(version: 2022_09_01_152612) do

  create_table "stats", id: { type: :string, limit: 255, default: "" }, force: :cascade do |t|
    t.integer "network_id", default: 0, null: false
    t.integer "offer_id", default: 0, null: false
    t.integer "offer_variant_id", null: false
    t.integer "affiliate_id", default: 0, null: false
    t.string "subid_1", limit: 1000, null: false
    t.string "subid_2", limit: 1000, null: false
    t.string "subid_3", limit: 1000, null: false
    t.integer "language_id", null: false
    t.string "http_user_agent", limit: 500, null: false
    t.string "http_referer", limit: 1000, null: false
    t.string "ip_address", limit: 40, null: false
    t.integer "clicks", null: false
    t.integer "conversions", null: false
    t.datetime "recorded_at", null: false
    t.decimal "true_pay", precision: 20, scale: 2, null: false
    t.decimal "affiliate_pay", precision: 20, scale: 2, null: false
    t.integer "affiliate_offer_id", null: false
    t.string "manual_notes", limit: 500, null: false
    t.string "status", limit: 100, null: false
    t.integer "approved", limit: 2, null: false
    t.integer "image_creative_id", null: false
    t.datetime "converted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vtm_page", limit: 255, null: false
    t.string "vtm_channel", limit: 255, null: false
    t.string "vtm_host", limit: 255, null: false
    t.integer "mkt_site_id", null: false
    t.integer "hits", null: false
    t.integer "mkt_url_id", null: false
    t.string "vtm_campaign", limit: 255, null: false
    t.string "ip_country", limit: 255, null: false
    t.string "approval", limit: 255, null: false
    t.integer "order_id", null: false
    t.string "step_name", limit: 255, null: false
    t.string "step_label", limit: 255, null: false
    t.string "true_conv_type", limit: 255, null: false
    t.string "affiliate_conv_type", limit: 255, null: false
    t.integer "lead_id", null: false
    t.string "s1", limit: 2000, null: false
    t.string "s2", limit: 2000, null: false
    t.string "s3", limit: 2000, null: false
    t.string "s4", limit: 2000, null: false
    t.boolean "is_bot", null: false
    t.integer "text_creative_id", null: false
    t.integer "channel_id", null: false
    t.integer "campaign_id", null: false
    t.integer "ad_group_id", null: false
    t.integer "ad_id", null: false
    t.string "keyword", limit: 255, null: false
    t.integer "share_creative_id", null: false
    t.datetime "captured_at", null: false
    t.string "isp", limit: 255, null: false
    t.string "browser", limit: 255, null: false
    t.string "browser_version", limit: 255, null: false
    t.string "device_type", limit: 255, null: false
    t.string "device_brand", limit: 255, null: false
    t.string "device_model", limit: 255, null: false
    t.string "aff_uniq_id", limit: 255, null: false
    t.string "ios_uniq", limit: 255, null: false
    t.string "android_uniq", limit: 255, null: false
    t.string "subid_4", limit: 1000, null: false
    t.string "subid_5", limit: 1000, null: false
    t.string "order_number", limit: 255, null: false
    t.string "gaid", limit: 255, null: false
    t.integer "email_creative_id", null: false
    t.decimal "qscore", precision: 10, scale: 2, null: false
    t.string "ad_slot_id", limit: 255, null: false
    t.integer "impression", null: false
    t.datetime "published_at", null: false
    t.string "adv_uniq_id", limit: 255, null: false
    t.string "forex", limit: 255, null: false
    t.string "original_currency", limit: 3, null: false
    t.string "attribution_level", limit: 256, null: false
    t.decimal "order_total", precision: 20, scale: 2, null: false
  end

end
