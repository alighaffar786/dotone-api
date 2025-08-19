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

ActiveRecord::Schema.define(version: 2025_07_31_040143) do

  create_table "ad_channels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
  end

  create_table "ad_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "max_cpc", precision: 8, scale: 2
  end

  create_table "ad_link_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.date "date"
    t.integer "impression", default: 0
    t.string "batch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_ad_link_stats_on_affiliate_id"
  end

  create_table "ad_slot_category_groups", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "ad_slot_id"
    t.integer "category_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ad_slot_offers", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "ad_slot_id"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ad_slots", id: :string, default: "", charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "client_html"
    t.string "display_format"
    t.string "name"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.string "subid_4"
    t.string "subid_5"
    t.string "status"
    t.integer "text_creative_id"
  end

  create_table "ad_tags", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "ad_id"
    t.integer "image_creative_id"
    t.integer "redirect_rate"
    t.integer "affiliate_offer_id"
  end

  create_table "ads", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ad_group_id"
    t.string "name"
    t.text "destination_url", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "landing_page_id"
    t.string "creative_type"
    t.string "other_creative_type"
    t.integer "banner_creative_width"
    t.integer "banner_creative_height"
    t.string "banner"
    t.text "description"
    t.string "target_location"
    t.integer "product_offer_id"
    t.integer "currency_id"
    t.string "ad_title"
    t.integer "offer_id"
    t.string "split"
  end

  create_table "advertiser_balances", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "network_id"
    t.datetime "recorded_at"
    t.decimal "credit", precision: 20, scale: 2
    t.decimal "debit", precision: 20, scale: 2
    t.decimal "tax", precision: 20, scale: 2
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "invoice_number", limit: 100
    t.decimal "invoice_amount", precision: 20, scale: 2
    t.datetime "invoice_date"
    t.string "record_type", limit: 50
  end

  create_table "advertiser_cats", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "network_id"
    t.integer "category_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_advertiser_cats_on_network_id"
  end

  create_table "aff_hashes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "entity_id"
    t.string "entity_type"
    t.text "flag"
    t.text "system_flag"
    t.index ["entity_type", "entity_id"], name: "index_aff_hashes_on_entity_type_and_entity_id"
  end

  create_table "affiliate_addresses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "affiliate_id"
    t.index ["affiliate_id"], name: "index_affiliate_addresses_on_affiliate_id"
  end

  create_table "affiliate_applications", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "experience"
    t.integer "address_id"
    t.string "company_name"
    t.string "job_title"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time_to_call"
    t.string "company_site"
    t.string "phone_number"
    t.integer "wl_company_id"
    t.integer "affiliate_id"
    t.boolean "accept_terms", default: false
    t.string "skype"
    t.string "line"
    t.string "qq"
    t.string "mobile_phone_number"
    t.string "wechat"
    t.string "facebook"
    t.string "twitter"
    t.string "linkedin"
    t.string "pinterest"
    t.string "tumbler"
    t.boolean "age_confirmed"
    t.datetime "accept_terms_at"
    t.datetime "age_confirmed_at"
    t.index ["affiliate_id"], name: "index_affiliate_applications_on_affiliate_id"
  end

  create_table "affiliate_assignments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "affiliate_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "display_order"
    t.integer "network_id"
    t.index ["affiliate_id"], name: "index_affiliate_assignments_on_affiliate_id"
    t.index ["network_id"], name: "index_affiliate_assignments_on_network_id"
  end

  create_table "affiliate_feed_countries", charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_feed_id", null: false
    t.integer "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_feed_id", "country_id"], name: "index_affiliate_feed_countries_on_feed_id_and_country_id", unique: true
    t.index ["affiliate_feed_id"], name: "index_affiliate_feed_countries_on_affiliate_feed_id"
    t.index ["country_id"], name: "index_affiliate_feed_countries_on_country_id"
  end

  create_table "affiliate_feeds", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.text "content"
    t.datetime "published_at"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.boolean "sticky", default: false
    t.datetime "sticky_until"
    t.string "role"
    t.string "feed_type"
    t.datetime "republished_at"
  end

  create_table "affiliate_logs", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "note_type"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "agent_type"
    t.integer "agent_id"
    t.string "contact_target"
    t.string "contact_media"
    t.string "contact_stage"
    t.string "sales_pipeline"
  end

  create_table "affiliate_offers", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "approval_status"
    t.decimal "custom_comission", precision: 20, scale: 2
    t.text "conversion_pixel_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "agree_to_terms", default: false
    t.integer "cap_size"
    t.integer "conversion_counter"
    t.string "status_summary"
    t.text "status_reason"
    t.text "conversion_pixel_s2s"
    t.datetime "last_conversion_at"
    t.integer "pixel_suppress_rate"
    t.integer "offer_id"
    t.text "backup_redirect"
    t.text "reapply_note"
    t.string "cap_notified_at"
    t.boolean "cap_notification_email", default: true
    t.integer "cap_time_zone"
    t.string "cap_redirect", default: "Soft"
    t.string "cap_type"
    t.datetime "cap_earliest_at"
    t.boolean "is_custom_commission", default: false
    t.string "event_draft_url"
    t.string "event_published_url"
    t.string "event_contract_signature"
    t.string "event_contract_signed_ip_address"
    t.datetime "event_contract_signed_at"
    t.text "event_supplement_notes"
    t.text "event_shipment_notes"
    t.text "event_promotion_notes"
    t.text "event_draft_notes"
    t.integer "site_info_id"
    t.string "phone_number"
    t.boolean "is_auto_applied", default: false
    t.datetime "activated_at"
    t.datetime "approval_status_changed_at"
    t.index ["affiliate_id"], name: "index_affiliate_offers_on_affiliate_id"
    t.index ["approval_status"], name: "index_affiliate_offers_on_approval_status"
    t.index ["offer_id"], name: "index_affiliate_offers_on_offer_id"
    t.index ["site_info_id"], name: "index_affiliate_offers_on_site_info_id"
    t.index ["updated_at"], name: "index_affiliate_offers_on_updated_at"
  end

  create_table "affiliate_payment_infos", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "payment_type"
    t.integer "affiliate_id"
    t.integer "affiliate_address_id"
    t.string "payee_name"
    t.string "branch"
    t.string "account_number"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "paypal_email_address"
    t.string "preferred_currency"
    t.boolean "confirmed", default: false
    t.string "bank_identification"
    t.string "branch_name"
    t.string "routing_number"
    t.string "bank_name"
    t.string "branch_identification"
    t.string "iban"
    t.string "bank_address"
    t.decimal "latest_commission", precision: 20, scale: 2
    t.datetime "confirmed_at"
    t.index ["affiliate_id"], name: "index_affiliate_payment_infos_on_affiliate_id"
  end

  create_table "affiliate_payments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "affiliate_payment_info_id"
    t.decimal "amount", precision: 20, scale: 2
    t.string "status"
    t.datetime "paid_at"
    t.datetime "period_start_at"
    t.datetime "period_end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.decimal "previous_amount", precision: 20, scale: 2
    t.decimal "referral_amount", precision: 20, scale: 2
    t.decimal "redeemed_amount", precision: 20, scale: 2
    t.boolean "has_invoice"
    t.decimal "affiliate_amount", precision: 20, scale: 2
    t.decimal "balance", precision: 20, scale: 2
    t.string "business_entity"
    t.string "payment_type"
    t.string "payee_name"
    t.string "branch"
    t.string "account_number"
    t.string "paypal_email_address"
    t.string "preferred_currency"
    t.string "address1"
    t.string "address2"
    t.string "zip_code"
    t.integer "country_id"
    t.string "city"
    t.string "state"
    t.boolean "confirmed", default: false
    t.string "branch_name"
    t.string "bank_identification"
    t.string "routing_number"
    t.string "tax_filing_country"
    t.string "payment_info_status"
    t.string "legal_resident_address"
    t.string "bank_name"
    t.string "branch_identification"
    t.string "iban"
    t.string "bank_address"
    t.string "conversion_file"
    t.string "tax_region"
    t.string "billing_region"
    t.date "start_date"
    t.date "end_date"
    t.date "paid_date"
    t.index ["affiliate_id"], name: "index_affiliate_payments_on_affiliate_id"
    t.index ["paid_at"], name: "index_affiliate_payments_on_paid_at"
  end

  create_table "affiliate_prospect_categories", charset: "latin1", force: :cascade do |t|
    t.integer "affiliate_prospect_id"
    t.integer "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_prospect_id", "category_id"], name: "idx_affiliate_prospect_id_category_id", unique: true
    t.index ["affiliate_prospect_id"], name: "index_affiliate_prospect_categories_on_affiliate_prospect_id"
    t.index ["category_id"], name: "index_affiliate_prospect_categories_on_category_id"
  end

  create_table "affiliate_search_logs", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "offer_keyword"
    t.integer "offer_keyword_count", default: 0
    t.string "product_keyword"
    t.integer "product_keyword_count", default: 0
    t.index ["affiliate_id", "date"], name: "index_affiliate_search_logs_on_affiliate_id_and_keyword_and_date"
    t.index ["affiliate_id"], name: "index_affiliate_search_logs_on_affiliate_id"
    t.index ["date"], name: "index_affiliate_search_logs_on_keyword_and_date"
  end

  create_table "affiliate_stat_captured_ats", primary_key: ["captured_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", options: "ENGINE=InnoDB\n/*!50100 PARTITION BY RANGE ( TO_DAYS(captured_at))\n(PARTITION p201601SUB00 VALUES LESS THAN (736330) ENGINE = InnoDB,\n PARTITION p201601SUB01 VALUES LESS THAN (736332) ENGINE = InnoDB,\n PARTITION p201601SUB02 VALUES LESS THAN (736334) ENGINE = InnoDB,\n PARTITION p201601SUB03 VALUES LESS THAN (736336) ENGINE = InnoDB,\n PARTITION p201601SUB04 VALUES LESS THAN (736338) ENGINE = InnoDB,\n PARTITION p201601SUB05 VALUES LESS THAN (736340) ENGINE = InnoDB,\n PARTITION p201601SUB06 VALUES LESS THAN (736342) ENGINE = InnoDB,\n PARTITION p201601SUB07 VALUES LESS THAN (736344) ENGINE = InnoDB,\n PARTITION p201601SUB08 VALUES LESS THAN (736346) ENGINE = InnoDB,\n PARTITION p201601SUB09 VALUES LESS THAN (736348) ENGINE = InnoDB,\n PARTITION p201601SUB10 VALUES LESS THAN (736350) ENGINE = InnoDB,\n PARTITION p201601SUB11 VALUES LESS THAN (736352) ENGINE = InnoDB,\n PARTITION p201601SUB12 VALUES LESS THAN (736354) ENGINE = InnoDB,\n PARTITION p201601SUB13 VALUES LESS THAN (736356) ENGINE = InnoDB,\n PARTITION p201601SUB14 VALUES LESS THAN (736358) ENGINE = InnoDB,\n PARTITION p201602SUB00 VALUES LESS THAN (736361) ENGINE = InnoDB,\n PARTITION p201602SUB01 VALUES LESS THAN (736363) ENGINE = InnoDB,\n PARTITION p201602SUB02 VALUES LESS THAN (736365) ENGINE = InnoDB,\n PARTITION p201602SUB03 VALUES LESS THAN (736367) ENGINE = InnoDB,\n PARTITION p201602SUB04 VALUES LESS THAN (736369) ENGINE = InnoDB,\n PARTITION p201602SUB05 VALUES LESS THAN (736371) ENGINE = InnoDB,\n PARTITION p201602SUB06 VALUES LESS THAN (736373) ENGINE = InnoDB,\n PARTITION p201602SUB07 VALUES LESS THAN (736375) ENGINE = InnoDB,\n PARTITION p201602SUB08 VALUES LESS THAN (736377) ENGINE = InnoDB,\n PARTITION p201602SUB09 VALUES LESS THAN (736379) ENGINE = InnoDB,\n PARTITION p201602SUB10 VALUES LESS THAN (736381) ENGINE = InnoDB,\n PARTITION p201602SUB11 VALUES LESS THAN (736383) ENGINE = InnoDB,\n PARTITION p201602SUB12 VALUES LESS THAN (736385) ENGINE = InnoDB,\n PARTITION p201602SUB13 VALUES LESS THAN (736387) ENGINE = InnoDB,\n PARTITION p201603SUB00 VALUES LESS THAN (736390) ENGINE = InnoDB,\n PARTITION p201603SUB01 VALUES LESS THAN (736392) ENGINE = InnoDB,\n PARTITION p201603SUB02 VALUES LESS THAN (736394) ENGINE = InnoDB,\n PARTITION p201603SUB03 VALUES LESS THAN (736396) ENGINE = InnoDB,\n PARTITION p201603SUB04 VALUES LESS THAN (736398) ENGINE = InnoDB,\n PARTITION p201603SUB05 VALUES LESS THAN (736400) ENGINE = InnoDB,\n PARTITION p201603SUB06 VALUES LESS THAN (736402) ENGINE = InnoDB,\n PARTITION p201603SUB07 VALUES LESS THAN (736404) ENGINE = InnoDB,\n PARTITION p201603SUB08 VALUES LESS THAN (736406) ENGINE = InnoDB,\n PARTITION p201603SUB09 VALUES LESS THAN (736408) ENGINE = InnoDB,\n PARTITION p201603SUB10 VALUES LESS THAN (736410) ENGINE = InnoDB,\n PARTITION p201603SUB11 VALUES LESS THAN (736412) ENGINE = InnoDB,\n PARTITION p201603SUB12 VALUES LESS THAN (736414) ENGINE = InnoDB,\n PARTITION p201603SUB13 VALUES LESS THAN (736416) ENGINE = InnoDB,\n PARTITION p201603SUB14 VALUES LESS THAN (736418) ENGINE = InnoDB,\n PARTITION p201604SUB00 VALUES LESS THAN (736421) ENGINE = InnoDB,\n PARTITION p201604SUB01 VALUES LESS THAN (736423) ENGINE = InnoDB,\n PARTITION p201604SUB02 VALUES LESS THAN (736425) ENGINE = InnoDB,\n PARTITION p201604SUB03 VALUES LESS THAN (736427) ENGINE = InnoDB,\n PARTITION p201604SUB04 VALUES LESS THAN (736429) ENGINE = InnoDB,\n PARTITION p201604SUB05 VALUES LESS THAN (736431) ENGINE = InnoDB,\n PARTITION p201604SUB06 VALUES LESS THAN (736433) ENGINE = InnoDB,\n PARTITION p201604SUB07 VALUES LESS THAN (736435) ENGINE = InnoDB,\n PARTITION p201604SUB08 VALUES LESS THAN (736437) ENGINE = InnoDB,\n PARTITION p201604SUB09 VALUES LESS THAN (736439) ENGINE = InnoDB,\n PARTITION p201604SUB10 VALUES LESS THAN (736441) ENGINE = InnoDB,\n PARTITION p201604SUB11 VALUES LESS THAN (736443) ENGINE = InnoDB,\n PARTITION p201604SUB12 VALUES LESS THAN (736445) ENGINE = InnoDB,\n PARTITION p201604SUB13 VALUES LESS THAN (736447) ENGINE = InnoDB,\n PARTITION p201604SUB14 VALUES LESS THAN (736449) ENGINE = InnoDB,\n PARTITION p201605SUB00 VALUES LESS THAN (736451) ENGINE = InnoDB,\n PARTITION p201605SUB01 VALUES LESS THAN (736453) ENGINE = InnoDB,\n PARTITION p201605SUB02 VALUES LESS THAN (736455) ENGINE = InnoDB,\n PARTITION p201605SUB03 VALUES LESS THAN (736457) ENGINE = InnoDB,\n PARTITION p201605SUB04 VALUES LESS THAN (736459) ENGINE = InnoDB,\n PARTITION p201605SUB05 VALUES LESS THAN (736461) ENGINE = InnoDB,\n PARTITION p201605SUB06 VALUES LESS THAN (736463) ENGINE = InnoDB,\n PARTITION p201605SUB07 VALUES LESS THAN (736465) ENGINE = InnoDB,\n PARTITION p201605SUB08 VALUES LESS THAN (736467) ENGINE = InnoDB,\n PARTITION p201605SUB09 VALUES LESS THAN (736469) ENGINE = InnoDB,\n PARTITION p201605SUB10 VALUES LESS THAN (736471) ENGINE = InnoDB,\n PARTITION p201605SUB11 VALUES LESS THAN (736473) ENGINE = InnoDB,\n PARTITION p201605SUB12 VALUES LESS THAN (736475) ENGINE = InnoDB,\n PARTITION p201605SUB13 VALUES LESS THAN (736477) ENGINE = InnoDB,\n PARTITION p201605SUB14 VALUES LESS THAN (736479) ENGINE = InnoDB,\n PARTITION p201606SUB00 VALUES LESS THAN (736482) ENGINE = InnoDB,\n PARTITION p201606SUB01 VALUES LESS THAN (736484) ENGINE = InnoDB,\n PARTITION p201606SUB02 VALUES LESS THAN (736486) ENGINE = InnoDB,\n PARTITION p201606SUB03 VALUES LESS THAN (736488) ENGINE = InnoDB,\n PARTITION p201606SUB04 VALUES LESS THAN (736490) ENGINE = InnoDB,\n PARTITION p201606SUB05 VALUES LESS THAN (736492) ENGINE = InnoDB,\n PARTITION p201606SUB06 VALUES LESS THAN (736494) ENGINE = InnoDB,\n PARTITION p201606SUB07 VALUES LESS THAN (736496) ENGINE = InnoDB,\n PARTITION p201606SUB08 VALUES LESS THAN (736498) ENGINE = InnoDB,\n PARTITION p201606SUB09 VALUES LESS THAN (736500) ENGINE = InnoDB,\n PARTITION p201606SUB10 VALUES LESS THAN (736502) ENGINE = InnoDB,\n PARTITION p201606SUB11 VALUES LESS THAN (736504) ENGINE = InnoDB,\n PARTITION p201606SUB12 VALUES LESS THAN (736506) ENGINE = InnoDB,\n PARTITION p201606SUB13 VALUES LESS THAN (736508) ENGINE = InnoDB,\n PARTITION p201606SUB14 VALUES LESS THAN (736510) ENGINE = InnoDB,\n PARTITION p201607SUB00 VALUES LESS THAN (736512) ENGINE = InnoDB,\n PARTITION p201607SUB01 VALUES LESS THAN (736514) ENGINE = InnoDB,\n PARTITION p201607SUB02 VALUES LESS THAN (736516) ENGINE = InnoDB,\n PARTITION p201607SUB03 VALUES LESS THAN (736518) ENGINE = InnoDB,\n PARTITION p201607SUB04 VALUES LESS THAN (736520) ENGINE = InnoDB,\n PARTITION p201607SUB05 VALUES LESS THAN (736522) ENGINE = InnoDB,\n PARTITION p201607SUB06 VALUES LESS THAN (736524) ENGINE = InnoDB,\n PARTITION p201607SUB07 VALUES LESS THAN (736526) ENGINE = InnoDB,\n PARTITION p201607SUB08 VALUES LESS THAN (736528) ENGINE = InnoDB,\n PARTITION p201607SUB09 VALUES LESS THAN (736530) ENGINE = InnoDB,\n PARTITION p201607SUB10 VALUES LESS THAN (736532) ENGINE = InnoDB,\n PARTITION p201607SUB11 VALUES LESS THAN (736534) ENGINE = InnoDB,\n PARTITION p201607SUB12 VALUES LESS THAN (736536) ENGINE = InnoDB,\n PARTITION p201607SUB13 VALUES LESS THAN (736538) ENGINE = InnoDB,\n PARTITION p201607SUB14 VALUES LESS THAN (736540) ENGINE = InnoDB,\n PARTITION p201608SUB00 VALUES LESS THAN (736543) ENGINE = InnoDB,\n PARTITION p201608SUB01 VALUES LESS THAN (736545) ENGINE = InnoDB,\n PARTITION p201608SUB02 VALUES LESS THAN (736547) ENGINE = InnoDB,\n PARTITION p201608SUB03 VALUES LESS THAN (736549) ENGINE = InnoDB,\n PARTITION p201608SUB04 VALUES LESS THAN (736551) ENGINE = InnoDB,\n PARTITION p201608SUB05 VALUES LESS THAN (736553) ENGINE = InnoDB,\n PARTITION p201608SUB06 VALUES LESS THAN (736555) ENGINE = InnoDB,\n PARTITION p201608SUB07 VALUES LESS THAN (736557) ENGINE = InnoDB,\n PARTITION p201608SUB08 VALUES LESS THAN (736559) ENGINE = InnoDB,\n PARTITION p201608SUB09 VALUES LESS THAN (736561) ENGINE = InnoDB,\n PARTITION p201608SUB10 VALUES LESS THAN (736563) ENGINE = InnoDB,\n PARTITION p201608SUB11 VALUES LESS THAN (736565) ENGINE = InnoDB,\n PARTITION p201608SUB12 VALUES LESS THAN (736567) ENGINE = InnoDB,\n PARTITION p201608SUB13 VALUES LESS THAN (736569) ENGINE = InnoDB,\n PARTITION p201608SUB14 VALUES LESS THAN (736571) ENGINE = InnoDB,\n PARTITION p201609SUB00 VALUES LESS THAN (736574) ENGINE = InnoDB,\n PARTITION p201609SUB01 VALUES LESS THAN (736576) ENGINE = InnoDB,\n PARTITION p201609SUB02 VALUES LESS THAN (736578) ENGINE = InnoDB,\n PARTITION p201609SUB03 VALUES LESS THAN (736580) ENGINE = InnoDB,\n PARTITION p201609SUB04 VALUES LESS THAN (736582) ENGINE = InnoDB,\n PARTITION p201609SUB05 VALUES LESS THAN (736584) ENGINE = InnoDB,\n PARTITION p201609SUB06 VALUES LESS THAN (736586) ENGINE = InnoDB,\n PARTITION p201609SUB07 VALUES LESS THAN (736588) ENGINE = InnoDB,\n PARTITION p201609SUB08 VALUES LESS THAN (736590) ENGINE = InnoDB,\n PARTITION p201609SUB09 VALUES LESS THAN (736592) ENGINE = InnoDB,\n PARTITION p201609SUB10 VALUES LESS THAN (736594) ENGINE = InnoDB,\n PARTITION p201609SUB11 VALUES LESS THAN (736596) ENGINE = InnoDB,\n PARTITION p201609SUB12 VALUES LESS THAN (736598) ENGINE = InnoDB,\n PARTITION p201609SUB13 VALUES LESS THAN (736600) ENGINE = InnoDB,\n PARTITION p201609SUB14 VALUES LESS THAN (736602) ENGINE = InnoDB,\n PARTITION p201610SUB00 VALUES LESS THAN (736604) ENGINE = InnoDB,\n PARTITION p201610SUB01 VALUES LESS THAN (736606) ENGINE = InnoDB,\n PARTITION p201610SUB02 VALUES LESS THAN (736608) ENGINE = InnoDB,\n PARTITION p201610SUB03 VALUES LESS THAN (736610) ENGINE = InnoDB,\n PARTITION p201610SUB04 VALUES LESS THAN (736612) ENGINE = InnoDB,\n PARTITION p201610SUB05 VALUES LESS THAN (736614) ENGINE = InnoDB,\n PARTITION p201610SUB06 VALUES LESS THAN (736616) ENGINE = InnoDB,\n PARTITION p201610SUB07 VALUES LESS THAN (736618) ENGINE = InnoDB,\n PARTITION p201610SUB08 VALUES LESS THAN (736620) ENGINE = InnoDB,\n PARTITION p201610SUB09 VALUES LESS THAN (736622) ENGINE = InnoDB,\n PARTITION p201610SUB10 VALUES LESS THAN (736624) ENGINE = InnoDB,\n PARTITION p201610SUB11 VALUES LESS THAN (736626) ENGINE = InnoDB,\n PARTITION p201610SUB12 VALUES LESS THAN (736628) ENGINE = InnoDB,\n PARTITION p201610SUB13 VALUES LESS THAN (736630) ENGINE = InnoDB,\n PARTITION p201610SUB14 VALUES LESS THAN (736632) ENGINE = InnoDB,\n PARTITION p201611SUB00 VALUES LESS THAN (736635) ENGINE = InnoDB,\n PARTITION p201611SUB01 VALUES LESS THAN (736637) ENGINE = InnoDB,\n PARTITION p201611SUB02 VALUES LESS THAN (736639) ENGINE = InnoDB,\n PARTITION p201611SUB03 VALUES LESS THAN (736641) ENGINE = InnoDB,\n PARTITION p201611SUB04 VALUES LESS THAN (736643) ENGINE = InnoDB,\n PARTITION p201611SUB05 VALUES LESS THAN (736645) ENGINE = InnoDB,\n PARTITION p201611SUB06 VALUES LESS THAN (736647) ENGINE = InnoDB,\n PARTITION p201611SUB07 VALUES LESS THAN (736649) ENGINE = InnoDB,\n PARTITION p201611SUB08 VALUES LESS THAN (736651) ENGINE = InnoDB,\n PARTITION p201611SUB09 VALUES LESS THAN (736653) ENGINE = InnoDB,\n PARTITION p201611SUB10 VALUES LESS THAN (736655) ENGINE = InnoDB,\n PARTITION p201611SUB11 VALUES LESS THAN (736657) ENGINE = InnoDB,\n PARTITION p201611SUB12 VALUES LESS THAN (736659) ENGINE = InnoDB,\n PARTITION p201611SUB13 VALUES LESS THAN (736661) ENGINE = InnoDB,\n PARTITION p201611SUB14 VALUES LESS THAN (736663) ENGINE = InnoDB,\n PARTITION p201612SUB00 VALUES LESS THAN (736665) ENGINE = InnoDB,\n PARTITION p201612SUB01 VALUES LESS THAN (736667) ENGINE = InnoDB,\n PARTITION p201612SUB02 VALUES LESS THAN (736669) ENGINE = InnoDB,\n PARTITION p201612SUB03 VALUES LESS THAN (736671) ENGINE = InnoDB,\n PARTITION p201612SUB04 VALUES LESS THAN (736673) ENGINE = InnoDB,\n PARTITION p201612SUB05 VALUES LESS THAN (736675) ENGINE = InnoDB,\n PARTITION p201612SUB06 VALUES LESS THAN (736677) ENGINE = InnoDB,\n PARTITION p201612SUB07 VALUES LESS THAN (736679) ENGINE = InnoDB,\n PARTITION p201612SUB08 VALUES LESS THAN (736681) ENGINE = InnoDB,\n PARTITION p201612SUB09 VALUES LESS THAN (736683) ENGINE = InnoDB,\n PARTITION p201612SUB10 VALUES LESS THAN (736685) ENGINE = InnoDB,\n PARTITION p201612SUB11 VALUES LESS THAN (736687) ENGINE = InnoDB,\n PARTITION p201612SUB12 VALUES LESS THAN (736689) ENGINE = InnoDB,\n PARTITION p201612SUB13 VALUES LESS THAN (736691) ENGINE = InnoDB,\n PARTITION p201612SUB14 VALUES LESS THAN (736693) ENGINE = InnoDB,\n PARTITION p201701SUB00 VALUES LESS THAN (736696) ENGINE = InnoDB,\n PARTITION p201701SUB01 VALUES LESS THAN (736698) ENGINE = InnoDB,\n PARTITION p201701SUB02 VALUES LESS THAN (736700) ENGINE = InnoDB,\n PARTITION p201701SUB03 VALUES LESS THAN (736702) ENGINE = InnoDB,\n PARTITION p201701SUB04 VALUES LESS THAN (736704) ENGINE = InnoDB,\n PARTITION p201701SUB05 VALUES LESS THAN (736706) ENGINE = InnoDB,\n PARTITION p201701SUB06 VALUES LESS THAN (736708) ENGINE = InnoDB,\n PARTITION p201701SUB07 VALUES LESS THAN (736710) ENGINE = InnoDB,\n PARTITION p201701SUB08 VALUES LESS THAN (736712) ENGINE = InnoDB,\n PARTITION p201701SUB09 VALUES LESS THAN (736714) ENGINE = InnoDB,\n PARTITION p201701SUB10 VALUES LESS THAN (736716) ENGINE = InnoDB,\n PARTITION p201701SUB11 VALUES LESS THAN (736718) ENGINE = InnoDB,\n PARTITION p201701SUB12 VALUES LESS THAN (736720) ENGINE = InnoDB,\n PARTITION p201701SUB13 VALUES LESS THAN (736722) ENGINE = InnoDB,\n PARTITION p201701SUB14 VALUES LESS THAN (736724) ENGINE = InnoDB,\n PARTITION p201702SUB00 VALUES LESS THAN (736727) ENGINE = InnoDB,\n PARTITION p201702SUB01 VALUES LESS THAN (736729) ENGINE = InnoDB,\n PARTITION p201702SUB02 VALUES LESS THAN (736731) ENGINE = InnoDB,\n PARTITION p201702SUB03 VALUES LESS THAN (736733) ENGINE = InnoDB,\n PARTITION p201702SUB04 VALUES LESS THAN (736735) ENGINE = InnoDB,\n PARTITION p201702SUB05 VALUES LESS THAN (736737) ENGINE = InnoDB,\n PARTITION p201702SUB06 VALUES LESS THAN (736739) ENGINE = InnoDB,\n PARTITION p201702SUB07 VALUES LESS THAN (736741) ENGINE = InnoDB,\n PARTITION p201702SUB08 VALUES LESS THAN (736743) ENGINE = InnoDB,\n PARTITION p201702SUB09 VALUES LESS THAN (736745) ENGINE = InnoDB,\n PARTITION p201702SUB10 VALUES LESS THAN (736747) ENGINE = InnoDB,\n PARTITION p201702SUB11 VALUES LESS THAN (736749) ENGINE = InnoDB,\n PARTITION p201702SUB12 VALUES LESS THAN (736751) ENGINE = InnoDB,\n PARTITION p201702SUB13 VALUES LESS THAN (736753) ENGINE = InnoDB,\n PARTITION p201703SUB00 VALUES LESS THAN (736755) ENGINE = InnoDB,\n PARTITION p201703SUB01 VALUES LESS THAN (736757) ENGINE = InnoDB,\n PARTITION p201703SUB02 VALUES LESS THAN (736759) ENGINE = InnoDB,\n PARTITION p201703SUB03 VALUES LESS THAN (736761) ENGINE = InnoDB,\n PARTITION p201703SUB04 VALUES LESS THAN (736763) ENGINE = InnoDB,\n PARTITION p201703SUB05 VALUES LESS THAN (736765) ENGINE = InnoDB,\n PARTITION p201703SUB06 VALUES LESS THAN (736767) ENGINE = InnoDB,\n PARTITION p201703SUB07 VALUES LESS THAN (736769) ENGINE = InnoDB,\n PARTITION p201703SUB08 VALUES LESS THAN (736771) ENGINE = InnoDB,\n PARTITION p201703SUB09 VALUES LESS THAN (736773) ENGINE = InnoDB,\n PARTITION p201703SUB10 VALUES LESS THAN (736775) ENGINE = InnoDB,\n PARTITION p201703SUB11 VALUES LESS THAN (736777) ENGINE = InnoDB,\n PARTITION p201703SUB12 VALUES LESS THAN (736779) ENGINE = InnoDB,\n PARTITION p201703SUB13 VALUES LESS THAN (736781) ENGINE = InnoDB,\n PARTITION p201703SUB14 VALUES LESS THAN (736783) ENGINE = InnoDB,\n PARTITION p201704SUB00 VALUES LESS THAN (736786) ENGINE = InnoDB,\n PARTITION p201704SUB01 VALUES LESS THAN (736788) ENGINE = InnoDB,\n PARTITION p201704SUB02 VALUES LESS THAN (736790) ENGINE = InnoDB,\n PARTITION p201704SUB03 VALUES LESS THAN (736792) ENGINE = InnoDB,\n PARTITION p201704SUB04 VALUES LESS THAN (736794) ENGINE = InnoDB,\n PARTITION p201704SUB05 VALUES LESS THAN (736796) ENGINE = InnoDB,\n PARTITION p201704SUB06 VALUES LESS THAN (736798) ENGINE = InnoDB,\n PARTITION p201704SUB07 VALUES LESS THAN (736800) ENGINE = InnoDB,\n PARTITION p201704SUB08 VALUES LESS THAN (736802) ENGINE = InnoDB,\n PARTITION p201704SUB09 VALUES LESS THAN (736804) ENGINE = InnoDB,\n PARTITION p201704SUB10 VALUES LESS THAN (736806) ENGINE = InnoDB,\n PARTITION p201704SUB11 VALUES LESS THAN (736808) ENGINE = InnoDB,\n PARTITION p201704SUB12 VALUES LESS THAN (736810) ENGINE = InnoDB,\n PARTITION p201704SUB13 VALUES LESS THAN (736812) ENGINE = InnoDB,\n PARTITION p201704SUB14 VALUES LESS THAN (736814) ENGINE = InnoDB,\n PARTITION p201705SUB00 VALUES LESS THAN (736816) ENGINE = InnoDB,\n PARTITION p201705SUB01 VALUES LESS THAN (736818) ENGINE = InnoDB,\n PARTITION p201705SUB02 VALUES LESS THAN (736820) ENGINE = InnoDB,\n PARTITION p201705SUB03 VALUES LESS THAN (736822) ENGINE = InnoDB,\n PARTITION p201705SUB04 VALUES LESS THAN (736824) ENGINE = InnoDB,\n PARTITION p201705SUB05 VALUES LESS THAN (736826) ENGINE = InnoDB,\n PARTITION p201705SUB06 VALUES LESS THAN (736828) ENGINE = InnoDB,\n PARTITION p201705SUB07 VALUES LESS THAN (736830) ENGINE = InnoDB,\n PARTITION p201705SUB08 VALUES LESS THAN (736832) ENGINE = InnoDB,\n PARTITION p201705SUB09 VALUES LESS THAN (736834) ENGINE = InnoDB,\n PARTITION p201705SUB10 VALUES LESS THAN (736836) ENGINE = InnoDB,\n PARTITION p201705SUB11 VALUES LESS THAN (736838) ENGINE = InnoDB,\n PARTITION p201705SUB12 VALUES LESS THAN (736840) ENGINE = InnoDB,\n PARTITION p201705SUB13 VALUES LESS THAN (736842) ENGINE = InnoDB,\n PARTITION p201705SUB14 VALUES LESS THAN (736844) ENGINE = InnoDB,\n PARTITION p201706SUB00 VALUES LESS THAN (736847) ENGINE = InnoDB,\n PARTITION p201706SUB01 VALUES LESS THAN (736849) ENGINE = InnoDB,\n PARTITION p201706SUB02 VALUES LESS THAN (736851) ENGINE = InnoDB,\n PARTITION p201706SUB03 VALUES LESS THAN (736853) ENGINE = InnoDB,\n PARTITION p201706SUB04 VALUES LESS THAN (736855) ENGINE = InnoDB,\n PARTITION p201706SUB05 VALUES LESS THAN (736857) ENGINE = InnoDB,\n PARTITION p201706SUB06 VALUES LESS THAN (736859) ENGINE = InnoDB,\n PARTITION p201706SUB07 VALUES LESS THAN (736861) ENGINE = InnoDB,\n PARTITION p201706SUB08 VALUES LESS THAN (736863) ENGINE = InnoDB,\n PARTITION p201706SUB09 VALUES LESS THAN (736865) ENGINE = InnoDB,\n PARTITION p201706SUB10 VALUES LESS THAN (736867) ENGINE = InnoDB,\n PARTITION p201706SUB11 VALUES LESS THAN (736869) ENGINE = InnoDB,\n PARTITION p201706SUB12 VALUES LESS THAN (736871) ENGINE = InnoDB,\n PARTITION p201706SUB13 VALUES LESS THAN (736873) ENGINE = InnoDB,\n PARTITION p201706SUB14 VALUES LESS THAN (736875) ENGINE = InnoDB,\n PARTITION p201707SUB00 VALUES LESS THAN (736877) ENGINE = InnoDB,\n PARTITION p201707SUB01 VALUES LESS THAN (736879) ENGINE = InnoDB,\n PARTITION p201707SUB02 VALUES LESS THAN (736881) ENGINE = InnoDB,\n PARTITION p201707SUB03 VALUES LESS THAN (736883) ENGINE = InnoDB,\n PARTITION p201707SUB04 VALUES LESS THAN (736885) ENGINE = InnoDB,\n PARTITION p201707SUB05 VALUES LESS THAN (736887) ENGINE = InnoDB,\n PARTITION p201707SUB06 VALUES LESS THAN (736889) ENGINE = InnoDB,\n PARTITION p201707SUB07 VALUES LESS THAN (736891) ENGINE = InnoDB,\n PARTITION p201707SUB08 VALUES LESS THAN (736893) ENGINE = InnoDB,\n PARTITION p201707SUB09 VALUES LESS THAN (736895) ENGINE = InnoDB,\n PARTITION p201707SUB10 VALUES LESS THAN (736897) ENGINE = InnoDB,\n PARTITION p201707SUB11 VALUES LESS THAN (736899) ENGINE = InnoDB,\n PARTITION p201707SUB12 VALUES LESS THAN (736901) ENGINE = InnoDB,\n PARTITION p201707SUB13 VALUES LESS THAN (736903) ENGINE = InnoDB,\n PARTITION p201707SUB14 VALUES LESS THAN (736905) ENGINE = InnoDB,\n PARTITION p201708SUB00 VALUES LESS THAN (736908) ENGINE = InnoDB,\n PARTITION p201708SUB01 VALUES LESS THAN (736910) ENGINE = InnoDB,\n PARTITION p201708SUB02 VALUES LESS THAN (736912) ENGINE = InnoDB,\n PARTITION p201708SUB03 VALUES LESS THAN (736914) ENGINE = InnoDB,\n PARTITION p201708SUB04 VALUES LESS THAN (736916) ENGINE = InnoDB,\n PARTITION p201708SUB05 VALUES LESS THAN (736918) ENGINE = InnoDB,\n PARTITION p201708SUB06 VALUES LESS THAN (736920) ENGINE = InnoDB,\n PARTITION p201708SUB07 VALUES LESS THAN (736922) ENGINE = InnoDB,\n PARTITION p201708SUB08 VALUES LESS THAN (736924) ENGINE = InnoDB,\n PARTITION p201708SUB09 VALUES LESS THAN (736926) ENGINE = InnoDB,\n PARTITION p201708SUB10 VALUES LESS THAN (736928) ENGINE = InnoDB,\n PARTITION p201708SUB11 VALUES LESS THAN (736930) ENGINE = InnoDB,\n PARTITION p201708SUB12 VALUES LESS THAN (736932) ENGINE = InnoDB,\n PARTITION p201708SUB13 VALUES LESS THAN (736934) ENGINE = InnoDB,\n PARTITION p201708SUB14 VALUES LESS THAN (736936) ENGINE = InnoDB,\n PARTITION p201709SUB00 VALUES LESS THAN (736939) ENGINE = InnoDB,\n PARTITION p201709SUB01 VALUES LESS THAN (736941) ENGINE = InnoDB,\n PARTITION p201709SUB02 VALUES LESS THAN (736943) ENGINE = InnoDB,\n PARTITION p201709SUB03 VALUES LESS THAN (736945) ENGINE = InnoDB,\n PARTITION p201709SUB04 VALUES LESS THAN (736947) ENGINE = InnoDB,\n PARTITION p201709SUB05 VALUES LESS THAN (736949) ENGINE = InnoDB,\n PARTITION p201709SUB06 VALUES LESS THAN (736951) ENGINE = InnoDB,\n PARTITION p201709SUB07 VALUES LESS THAN (736953) ENGINE = InnoDB,\n PARTITION p201709SUB08 VALUES LESS THAN (736955) ENGINE = InnoDB,\n PARTITION p201709SUB09 VALUES LESS THAN (736957) ENGINE = InnoDB,\n PARTITION p201709SUB10 VALUES LESS THAN (736959) ENGINE = InnoDB,\n PARTITION p201709SUB11 VALUES LESS THAN (736961) ENGINE = InnoDB,\n PARTITION p201709SUB12 VALUES LESS THAN (736963) ENGINE = InnoDB,\n PARTITION p201709SUB13 VALUES LESS THAN (736965) ENGINE = InnoDB,\n PARTITION p201709SUB14 VALUES LESS THAN (736967) ENGINE = InnoDB,\n PARTITION p201710SUB00 VALUES LESS THAN (736969) ENGINE = InnoDB,\n PARTITION p201710SUB01 VALUES LESS THAN (736971) ENGINE = InnoDB,\n PARTITION p201710SUB02 VALUES LESS THAN (736973) ENGINE = InnoDB,\n PARTITION p201710SUB03 VALUES LESS THAN (736975) ENGINE = InnoDB,\n PARTITION p201710SUB04 VALUES LESS THAN (736977) ENGINE = InnoDB,\n PARTITION p201710SUB05 VALUES LESS THAN (736979) ENGINE = InnoDB,\n PARTITION p201710SUB06 VALUES LESS THAN (736981) ENGINE = InnoDB,\n PARTITION p201710SUB07 VALUES LESS THAN (736983) ENGINE = InnoDB,\n PARTITION p201710SUB08 VALUES LESS THAN (736985) ENGINE = InnoDB,\n PARTITION p201710SUB09 VALUES LESS THAN (736987) ENGINE = InnoDB,\n PARTITION p201710SUB10 VALUES LESS THAN (736989) ENGINE = InnoDB,\n PARTITION p201710SUB11 VALUES LESS THAN (736991) ENGINE = InnoDB,\n PARTITION p201710SUB12 VALUES LESS THAN (736993) ENGINE = InnoDB,\n PARTITION p201710SUB13 VALUES LESS THAN (736995) ENGINE = InnoDB,\n PARTITION p201710SUB14 VALUES LESS THAN (736997) ENGINE = InnoDB,\n PARTITION p201711SUB00 VALUES LESS THAN (737000) ENGINE = InnoDB,\n PARTITION p201711SUB01 VALUES LESS THAN (737002) ENGINE = InnoDB,\n PARTITION p201711SUB02 VALUES LESS THAN (737004) ENGINE = InnoDB,\n PARTITION p201711SUB03 VALUES LESS THAN (737006) ENGINE = InnoDB,\n PARTITION p201711SUB04 VALUES LESS THAN (737008) ENGINE = InnoDB,\n PARTITION p201711SUB05 VALUES LESS THAN (737010) ENGINE = InnoDB,\n PARTITION p201711SUB06 VALUES LESS THAN (737012) ENGINE = InnoDB,\n PARTITION p201711SUB07 VALUES LESS THAN (737014) ENGINE = InnoDB,\n PARTITION p201711SUB08 VALUES LESS THAN (737016) ENGINE = InnoDB,\n PARTITION p201711SUB09 VALUES LESS THAN (737018) ENGINE = InnoDB,\n PARTITION p201711SUB10 VALUES LESS THAN (737020) ENGINE = InnoDB,\n PARTITION p201711SUB11 VALUES LESS THAN (737022) ENGINE = InnoDB,\n PARTITION p201711SUB12 VALUES LESS THAN (737024) ENGINE = InnoDB,\n PARTITION p201711SUB13 VALUES LESS THAN (737026) ENGINE = InnoDB,\n PARTITION p201711SUB14 VALUES LESS THAN (737028) ENGINE = InnoDB,\n PARTITION p201712SUB00 VALUES LESS THAN (737030) ENGINE = InnoDB,\n PARTITION p201712SUB01 VALUES LESS THAN (737032) ENGINE = InnoDB,\n PARTITION p201712SUB02 VALUES LESS THAN (737034) ENGINE = InnoDB,\n PARTITION p201712SUB03 VALUES LESS THAN (737036) ENGINE = InnoDB,\n PARTITION p201712SUB04 VALUES LESS THAN (737038) ENGINE = InnoDB,\n PARTITION p201712SUB05 VALUES LESS THAN (737040) ENGINE = InnoDB,\n PARTITION p201712SUB06 VALUES LESS THAN (737042) ENGINE = InnoDB,\n PARTITION p201712SUB07 VALUES LESS THAN (737044) ENGINE = InnoDB,\n PARTITION p201712SUB08 VALUES LESS THAN (737046) ENGINE = InnoDB,\n PARTITION p201712SUB09 VALUES LESS THAN (737048) ENGINE = InnoDB,\n PARTITION p201712SUB10 VALUES LESS THAN (737050) ENGINE = InnoDB,\n PARTITION p201712SUB11 VALUES LESS THAN (737052) ENGINE = InnoDB,\n PARTITION p201712SUB12 VALUES LESS THAN (737054) ENGINE = InnoDB,\n PARTITION p201712SUB13 VALUES LESS THAN (737056) ENGINE = InnoDB,\n PARTITION p201712SUB14 VALUES LESS THAN (737058) ENGINE = InnoDB,\n PARTITION p201801SUB00 VALUES LESS THAN (737061) ENGINE = InnoDB,\n PARTITION p201801SUB01 VALUES LESS THAN (737063) ENGINE = InnoDB,\n PARTITION p201801SUB02 VALUES LESS THAN (737065) ENGINE = InnoDB,\n PARTITION p201801SUB03 VALUES LESS THAN (737067) ENGINE = InnoDB,\n PARTITION p201801SUB04 VALUES LESS THAN (737069) ENGINE = InnoDB,\n PARTITION p201801SUB05 VALUES LESS THAN (737071) ENGINE = InnoDB,\n PARTITION p201801SUB06 VALUES LESS THAN (737073) ENGINE = InnoDB,\n PARTITION p201801SUB07 VALUES LESS THAN (737075) ENGINE = InnoDB,\n PARTITION p201801SUB08 VALUES LESS THAN (737077) ENGINE = InnoDB,\n PARTITION p201801SUB09 VALUES LESS THAN (737079) ENGINE = InnoDB,\n PARTITION p201801SUB10 VALUES LESS THAN (737081) ENGINE = InnoDB,\n PARTITION p201801SUB11 VALUES LESS THAN (737083) ENGINE = InnoDB,\n PARTITION p201801SUB12 VALUES LESS THAN (737085) ENGINE = InnoDB,\n PARTITION p201801SUB13 VALUES LESS THAN (737087) ENGINE = InnoDB,\n PARTITION p201801SUB14 VALUES LESS THAN (737089) ENGINE = InnoDB,\n PARTITION p201802SUB00 VALUES LESS THAN (737092) ENGINE = InnoDB,\n PARTITION p201802SUB01 VALUES LESS THAN (737094) ENGINE = InnoDB,\n PARTITION p201802SUB02 VALUES LESS THAN (737096) ENGINE = InnoDB,\n PARTITION p201802SUB03 VALUES LESS THAN (737098) ENGINE = InnoDB,\n PARTITION p201802SUB04 VALUES LESS THAN (737100) ENGINE = InnoDB,\n PARTITION p201802SUB05 VALUES LESS THAN (737102) ENGINE = InnoDB,\n PARTITION p201802SUB06 VALUES LESS THAN (737104) ENGINE = InnoDB,\n PARTITION p201802SUB07 VALUES LESS THAN (737106) ENGINE = InnoDB,\n PARTITION p201802SUB08 VALUES LESS THAN (737108) ENGINE = InnoDB,\n PARTITION p201802SUB09 VALUES LESS THAN (737110) ENGINE = InnoDB,\n PARTITION p201802SUB10 VALUES LESS THAN (737112) ENGINE = InnoDB,\n PARTITION p201802SUB11 VALUES LESS THAN (737114) ENGINE = InnoDB,\n PARTITION p201802SUB12 VALUES LESS THAN (737116) ENGINE = InnoDB,\n PARTITION p201802SUB13 VALUES LESS THAN (737118) ENGINE = InnoDB,\n PARTITION p201803SUB00 VALUES LESS THAN (737120) ENGINE = InnoDB,\n PARTITION p201803SUB01 VALUES LESS THAN (737122) ENGINE = InnoDB,\n PARTITION p201803SUB02 VALUES LESS THAN (737124) ENGINE = InnoDB,\n PARTITION p201803SUB03 VALUES LESS THAN (737126) ENGINE = InnoDB,\n PARTITION p201803SUB04 VALUES LESS THAN (737128) ENGINE = InnoDB,\n PARTITION p201803SUB05 VALUES LESS THAN (737130) ENGINE = InnoDB,\n PARTITION p201803SUB06 VALUES LESS THAN (737132) ENGINE = InnoDB,\n PARTITION p201803SUB07 VALUES LESS THAN (737134) ENGINE = InnoDB,\n PARTITION p201803SUB08 VALUES LESS THAN (737136) ENGINE = InnoDB,\n PARTITION p201803SUB09 VALUES LESS THAN (737138) ENGINE = InnoDB,\n PARTITION p201803SUB10 VALUES LESS THAN (737140) ENGINE = InnoDB,\n PARTITION p201803SUB11 VALUES LESS THAN (737142) ENGINE = InnoDB,\n PARTITION p201803SUB12 VALUES LESS THAN (737144) ENGINE = InnoDB,\n PARTITION p201803SUB13 VALUES LESS THAN (737146) ENGINE = InnoDB,\n PARTITION p201803SUB14 VALUES LESS THAN (737148) ENGINE = InnoDB,\n PARTITION p201804SUB00 VALUES LESS THAN (737151) ENGINE = InnoDB,\n PARTITION p201804SUB01 VALUES LESS THAN (737153) ENGINE = InnoDB,\n PARTITION p201804SUB02 VALUES LESS THAN (737155) ENGINE = InnoDB,\n PARTITION p201804SUB03 VALUES LESS THAN (737157) ENGINE = InnoDB,\n PARTITION p201804SUB04 VALUES LESS THAN (737159) ENGINE = InnoDB,\n PARTITION p201804SUB05 VALUES LESS THAN (737161) ENGINE = InnoDB,\n PARTITION p201804SUB06 VALUES LESS THAN (737163) ENGINE = InnoDB,\n PARTITION p201804SUB07 VALUES LESS THAN (737165) ENGINE = InnoDB,\n PARTITION p201804SUB08 VALUES LESS THAN (737167) ENGINE = InnoDB,\n PARTITION p201804SUB09 VALUES LESS THAN (737169) ENGINE = InnoDB,\n PARTITION p201804SUB10 VALUES LESS THAN (737171) ENGINE = InnoDB,\n PARTITION p201804SUB11 VALUES LESS THAN (737173) ENGINE = InnoDB,\n PARTITION p201804SUB12 VALUES LESS THAN (737175) ENGINE = InnoDB,\n PARTITION p201804SUB13 VALUES LESS THAN (737177) ENGINE = InnoDB,\n PARTITION p201804SUB14 VALUES LESS THAN (737179) ENGINE = InnoDB,\n PARTITION p201805SUB00 VALUES LESS THAN (737181) ENGINE = InnoDB,\n PARTITION p201805SUB01 VALUES LESS THAN (737183) ENGINE = InnoDB,\n PARTITION p201805SUB02 VALUES LESS THAN (737185) ENGINE = InnoDB,\n PARTITION p201805SUB03 VALUES LESS THAN (737187) ENGINE = InnoDB,\n PARTITION p201805SUB04 VALUES LESS THAN (737189) ENGINE = InnoDB,\n PARTITION p201805SUB05 VALUES LESS THAN (737191) ENGINE = InnoDB,\n PARTITION p201805SUB06 VALUES LESS THAN (737193) ENGINE = InnoDB,\n PARTITION p201805SUB07 VALUES LESS THAN (737195) ENGINE = InnoDB,\n PARTITION p201805SUB08 VALUES LESS THAN (737197) ENGINE = InnoDB,\n PARTITION p201805SUB09 VALUES LESS THAN (737199) ENGINE = InnoDB,\n PARTITION p201805SUB10 VALUES LESS THAN (737201) ENGINE = InnoDB,\n PARTITION p201805SUB11 VALUES LESS THAN (737203) ENGINE = InnoDB,\n PARTITION p201805SUB12 VALUES LESS THAN (737205) ENGINE = InnoDB,\n PARTITION p201805SUB13 VALUES LESS THAN (737207) ENGINE = InnoDB,\n PARTITION p201805SUB14 VALUES LESS THAN (737209) ENGINE = InnoDB,\n PARTITION p201806SUB00 VALUES LESS THAN (737212) ENGINE = InnoDB,\n PARTITION p201806SUB01 VALUES LESS THAN (737214) ENGINE = InnoDB,\n PARTITION p201806SUB02 VALUES LESS THAN (737216) ENGINE = InnoDB,\n PARTITION p201806SUB03 VALUES LESS THAN (737218) ENGINE = InnoDB,\n PARTITION p201806SUB04 VALUES LESS THAN (737220) ENGINE = InnoDB,\n PARTITION p201806SUB05 VALUES LESS THAN (737222) ENGINE = InnoDB,\n PARTITION p201806SUB06 VALUES LESS THAN (737224) ENGINE = InnoDB,\n PARTITION p201806SUB07 VALUES LESS THAN (737226) ENGINE = InnoDB,\n PARTITION p201806SUB08 VALUES LESS THAN (737228) ENGINE = InnoDB,\n PARTITION p201806SUB09 VALUES LESS THAN (737230) ENGINE = InnoDB,\n PARTITION p201806SUB10 VALUES LESS THAN (737232) ENGINE = InnoDB,\n PARTITION p201806SUB11 VALUES LESS THAN (737234) ENGINE = InnoDB,\n PARTITION p201806SUB12 VALUES LESS THAN (737236) ENGINE = InnoDB,\n PARTITION p201806SUB13 VALUES LESS THAN (737238) ENGINE = InnoDB,\n PARTITION p201806SUB14 VALUES LESS THAN (737240) ENGINE = InnoDB,\n PARTITION p201807SUB00 VALUES LESS THAN (737242) ENGINE = InnoDB,\n PARTITION p201807SUB01 VALUES LESS THAN (737244) ENGINE = InnoDB,\n PARTITION p201807SUB02 VALUES LESS THAN (737246) ENGINE = InnoDB,\n PARTITION p201807SUB03 VALUES LESS THAN (737248) ENGINE = InnoDB,\n PARTITION p201807SUB04 VALUES LESS THAN (737250) ENGINE = InnoDB,\n PARTITION p201807SUB05 VALUES LESS THAN (737252) ENGINE = InnoDB,\n PARTITION p201807SUB06 VALUES LESS THAN (737254) ENGINE = InnoDB,\n PARTITION p201807SUB07 VALUES LESS THAN (737256) ENGINE = InnoDB,\n PARTITION p201807SUB08 VALUES LESS THAN (737258) ENGINE = InnoDB,\n PARTITION p201807SUB09 VALUES LESS THAN (737260) ENGINE = InnoDB,\n PARTITION p201807SUB10 VALUES LESS THAN (737262) ENGINE = InnoDB,\n PARTITION p201807SUB11 VALUES LESS THAN (737264) ENGINE = InnoDB,\n PARTITION p201807SUB12 VALUES LESS THAN (737266) ENGINE = InnoDB,\n PARTITION p201807SUB13 VALUES LESS THAN (737268) ENGINE = InnoDB,\n PARTITION p201807SUB14 VALUES LESS THAN (737270) ENGINE = InnoDB,\n PARTITION p201808SUB00 VALUES LESS THAN (737273) ENGINE = InnoDB,\n PARTITION p201808SUB01 VALUES LESS THAN (737275) ENGINE = InnoDB,\n PARTITION p201808SUB02 VALUES LESS THAN (737277) ENGINE = InnoDB,\n PARTITION p201808SUB03 VALUES LESS THAN (737279) ENGINE = InnoDB,\n PARTITION p201808SUB04 VALUES LESS THAN (737281) ENGINE = InnoDB,\n PARTITION p201808SUB05 VALUES LESS THAN (737283) ENGINE = InnoDB,\n PARTITION p201808SUB06 VALUES LESS THAN (737285) ENGINE = InnoDB,\n PARTITION p201808SUB07 VALUES LESS THAN (737287) ENGINE = InnoDB,\n PARTITION p201808SUB08 VALUES LESS THAN (737289) ENGINE = InnoDB,\n PARTITION p201808SUB09 VALUES LESS THAN (737291) ENGINE = InnoDB,\n PARTITION p201808SUB10 VALUES LESS THAN (737293) ENGINE = InnoDB,\n PARTITION p201808SUB11 VALUES LESS THAN (737295) ENGINE = InnoDB,\n PARTITION p201808SUB12 VALUES LESS THAN (737297) ENGINE = InnoDB,\n PARTITION p201808SUB13 VALUES LESS THAN (737299) ENGINE = InnoDB,\n PARTITION p201808SUB14 VALUES LESS THAN (737301) ENGINE = InnoDB,\n PARTITION p201809SUB00 VALUES LESS THAN (737304) ENGINE = InnoDB,\n PARTITION p201809SUB01 VALUES LESS THAN (737306) ENGINE = InnoDB,\n PARTITION p201809SUB02 VALUES LESS THAN (737308) ENGINE = InnoDB,\n PARTITION p201809SUB03 VALUES LESS THAN (737310) ENGINE = InnoDB,\n PARTITION p201809SUB04 VALUES LESS THAN (737312) ENGINE = InnoDB,\n PARTITION p201809SUB05 VALUES LESS THAN (737314) ENGINE = InnoDB,\n PARTITION p201809SUB06 VALUES LESS THAN (737316) ENGINE = InnoDB,\n PARTITION p201809SUB07 VALUES LESS THAN (737318) ENGINE = InnoDB,\n PARTITION p201809SUB08 VALUES LESS THAN (737320) ENGINE = InnoDB,\n PARTITION p201809SUB09 VALUES LESS THAN (737322) ENGINE = InnoDB,\n PARTITION p201809SUB10 VALUES LESS THAN (737324) ENGINE = InnoDB,\n PARTITION p201809SUB11 VALUES LESS THAN (737326) ENGINE = InnoDB,\n PARTITION p201809SUB12 VALUES LESS THAN (737328) ENGINE = InnoDB,\n PARTITION p201809SUB13 VALUES LESS THAN (737330) ENGINE = InnoDB,\n PARTITION p201809SUB14 VALUES LESS THAN (737332) ENGINE = InnoDB,\n PARTITION p201810SUB00 VALUES LESS THAN (737334) ENGINE = InnoDB,\n PARTITION p201810SUB01 VALUES LESS THAN (737336) ENGINE = InnoDB,\n PARTITION p201810SUB02 VALUES LESS THAN (737338) ENGINE = InnoDB,\n PARTITION p201810SUB03 VALUES LESS THAN (737340) ENGINE = InnoDB,\n PARTITION p201810SUB04 VALUES LESS THAN (737342) ENGINE = InnoDB,\n PARTITION p201810SUB05 VALUES LESS THAN (737344) ENGINE = InnoDB,\n PARTITION p201810SUB06 VALUES LESS THAN (737346) ENGINE = InnoDB,\n PARTITION p201810SUB07 VALUES LESS THAN (737348) ENGINE = InnoDB,\n PARTITION p201810SUB08 VALUES LESS THAN (737350) ENGINE = InnoDB,\n PARTITION p201810SUB09 VALUES LESS THAN (737352) ENGINE = InnoDB,\n PARTITION p201810SUB10 VALUES LESS THAN (737354) ENGINE = InnoDB,\n PARTITION p201810SUB11 VALUES LESS THAN (737356) ENGINE = InnoDB,\n PARTITION p201810SUB12 VALUES LESS THAN (737358) ENGINE = InnoDB,\n PARTITION p201810SUB13 VALUES LESS THAN (737360) ENGINE = InnoDB,\n PARTITION p201810SUB14 VALUES LESS THAN (737362) ENGINE = InnoDB,\n PARTITION p201811SUB00 VALUES LESS THAN (737365) ENGINE = InnoDB,\n PARTITION p201811SUB01 VALUES LESS THAN (737367) ENGINE = InnoDB,\n PARTITION p201811SUB02 VALUES LESS THAN (737369) ENGINE = InnoDB,\n PARTITION p201811SUB03 VALUES LESS THAN (737371) ENGINE = InnoDB,\n PARTITION p201811SUB04 VALUES LESS THAN (737373) ENGINE = InnoDB,\n PARTITION p201811SUB05 VALUES LESS THAN (737375) ENGINE = InnoDB,\n PARTITION p201811SUB06 VALUES LESS THAN (737377) ENGINE = InnoDB,\n PARTITION p201811SUB07 VALUES LESS THAN (737379) ENGINE = InnoDB,\n PARTITION p201811SUB08 VALUES LESS THAN (737381) ENGINE = InnoDB,\n PARTITION p201811SUB09 VALUES LESS THAN (737383) ENGINE = InnoDB,\n PARTITION p201811SUB10 VALUES LESS THAN (737385) ENGINE = InnoDB,\n PARTITION p201811SUB11 VALUES LESS THAN (737387) ENGINE = InnoDB,\n PARTITION p201811SUB12 VALUES LESS THAN (737389) ENGINE = InnoDB,\n PARTITION p201811SUB13 VALUES LESS THAN (737391) ENGINE = InnoDB,\n PARTITION p201811SUB14 VALUES LESS THAN (737393) ENGINE = InnoDB,\n PARTITION p201812SUB00 VALUES LESS THAN (737395) ENGINE = InnoDB,\n PARTITION p201812SUB01 VALUES LESS THAN (737397) ENGINE = InnoDB,\n PARTITION p201812SUB02 VALUES LESS THAN (737399) ENGINE = InnoDB,\n PARTITION p201812SUB03 VALUES LESS THAN (737401) ENGINE = InnoDB,\n PARTITION p201812SUB04 VALUES LESS THAN (737403) ENGINE = InnoDB,\n PARTITION p201812SUB05 VALUES LESS THAN (737405) ENGINE = InnoDB,\n PARTITION p201812SUB06 VALUES LESS THAN (737407) ENGINE = InnoDB,\n PARTITION p201812SUB07 VALUES LESS THAN (737409) ENGINE = InnoDB,\n PARTITION p201812SUB08 VALUES LESS THAN (737411) ENGINE = InnoDB,\n PARTITION p201812SUB09 VALUES LESS THAN (737413) ENGINE = InnoDB,\n PARTITION p201812SUB10 VALUES LESS THAN (737415) ENGINE = InnoDB,\n PARTITION p201812SUB11 VALUES LESS THAN (737417) ENGINE = InnoDB,\n PARTITION p201812SUB12 VALUES LESS THAN (737419) ENGINE = InnoDB,\n PARTITION p201812SUB13 VALUES LESS THAN (737421) ENGINE = InnoDB,\n PARTITION p201812SUB14 VALUES LESS THAN (737423) ENGINE = InnoDB,\n PARTITION p201901SUB00 VALUES LESS THAN (737426) ENGINE = InnoDB,\n PARTITION p201901SUB01 VALUES LESS THAN (737428) ENGINE = InnoDB,\n PARTITION p201901SUB02 VALUES LESS THAN (737430) ENGINE = InnoDB,\n PARTITION p201901SUB03 VALUES LESS THAN (737432) ENGINE = InnoDB,\n PARTITION p201901SUB04 VALUES LESS THAN (737434) ENGINE = InnoDB,\n PARTITION p201901SUB05 VALUES LESS THAN (737436) ENGINE = InnoDB,\n PARTITION p201901SUB06 VALUES LESS THAN (737438) ENGINE = InnoDB,\n PARTITION p201901SUB07 VALUES LESS THAN (737440) ENGINE = InnoDB,\n PARTITION p201901SUB08 VALUES LESS THAN (737442) ENGINE = InnoDB,\n PARTITION p201901SUB09 VALUES LESS THAN (737444) ENGINE = InnoDB,\n PARTITION p201901SUB10 VALUES LESS THAN (737446) ENGINE = InnoDB,\n PARTITION p201901SUB11 VALUES LESS THAN (737448) ENGINE = InnoDB,\n PARTITION p201901SUB12 VALUES LESS THAN (737450) ENGINE = InnoDB,\n PARTITION p201901SUB13 VALUES LESS THAN (737452) ENGINE = InnoDB,\n PARTITION p201901SUB14 VALUES LESS THAN (737454) ENGINE = InnoDB,\n PARTITION p201902SUB00 VALUES LESS THAN (737457) ENGINE = InnoDB,\n PARTITION p201902SUB01 VALUES LESS THAN (737459) ENGINE = InnoDB,\n PARTITION p201902SUB02 VALUES LESS THAN (737461) ENGINE = InnoDB,\n PARTITION p201902SUB03 VALUES LESS THAN (737463) ENGINE = InnoDB,\n PARTITION p201902SUB04 VALUES LESS THAN (737465) ENGINE = InnoDB,\n PARTITION p201902SUB05 VALUES LESS THAN (737467) ENGINE = InnoDB,\n PARTITION p201902SUB06 VALUES LESS THAN (737469) ENGINE = InnoDB,\n PARTITION p201902SUB07 VALUES LESS THAN (737471) ENGINE = InnoDB,\n PARTITION p201902SUB08 VALUES LESS THAN (737473) ENGINE = InnoDB,\n PARTITION p201902SUB09 VALUES LESS THAN (737475) ENGINE = InnoDB,\n PARTITION p201902SUB10 VALUES LESS THAN (737477) ENGINE = InnoDB,\n PARTITION p201902SUB11 VALUES LESS THAN (737479) ENGINE = InnoDB,\n PARTITION p201902SUB12 VALUES LESS THAN (737481) ENGINE = InnoDB,\n PARTITION p201902SUB13 VALUES LESS THAN (737483) ENGINE = InnoDB,\n PARTITION p201903SUB00 VALUES LESS THAN (737485) ENGINE = InnoDB,\n PARTITION p201903SUB01 VALUES LESS THAN (737487) ENGINE = InnoDB,\n PARTITION p201903SUB02 VALUES LESS THAN (737489) ENGINE = InnoDB,\n PARTITION p201903SUB03 VALUES LESS THAN (737491) ENGINE = InnoDB,\n PARTITION p201903SUB04 VALUES LESS THAN (737493) ENGINE = InnoDB,\n PARTITION p201903SUB05 VALUES LESS THAN (737495) ENGINE = InnoDB,\n PARTITION p201903SUB06 VALUES LESS THAN (737497) ENGINE = InnoDB,\n PARTITION p201903SUB07 VALUES LESS THAN (737499) ENGINE = InnoDB,\n PARTITION p201903SUB08 VALUES LESS THAN (737501) ENGINE = InnoDB,\n PARTITION p201903SUB09 VALUES LESS THAN (737503) ENGINE = InnoDB,\n PARTITION p201903SUB10 VALUES LESS THAN (737505) ENGINE = InnoDB,\n PARTITION p201903SUB11 VALUES LESS THAN (737507) ENGINE = InnoDB,\n PARTITION p201903SUB12 VALUES LESS THAN (737509) ENGINE = InnoDB,\n PARTITION p201903SUB13 VALUES LESS THAN (737511) ENGINE = InnoDB,\n PARTITION p201903SUB14 VALUES LESS THAN (737513) ENGINE = InnoDB,\n PARTITION p201904SUB00 VALUES LESS THAN (737516) ENGINE = InnoDB,\n PARTITION p201904SUB01 VALUES LESS THAN (737518) ENGINE = InnoDB,\n PARTITION p201904SUB02 VALUES LESS THAN (737520) ENGINE = InnoDB,\n PARTITION p201904SUB03 VALUES LESS THAN (737522) ENGINE = InnoDB,\n PARTITION p201904SUB04 VALUES LESS THAN (737524) ENGINE = InnoDB,\n PARTITION p201904SUB05 VALUES LESS THAN (737526) ENGINE = InnoDB,\n PARTITION p201904SUB06 VALUES LESS THAN (737528) ENGINE = InnoDB,\n PARTITION p201904SUB07 VALUES LESS THAN (737530) ENGINE = InnoDB,\n PARTITION p201904SUB08 VALUES LESS THAN (737532) ENGINE = InnoDB,\n PARTITION p201904SUB09 VALUES LESS THAN (737534) ENGINE = InnoDB,\n PARTITION p201904SUB10 VALUES LESS THAN (737536) ENGINE = InnoDB,\n PARTITION p201904SUB11 VALUES LESS THAN (737538) ENGINE = InnoDB,\n PARTITION p201904SUB12 VALUES LESS THAN (737540) ENGINE = InnoDB,\n PARTITION p201904SUB13 VALUES LESS THAN (737542) ENGINE = InnoDB,\n PARTITION p201904SUB14 VALUES LESS THAN (737544) ENGINE = InnoDB,\n PARTITION p201905SUB00 VALUES LESS THAN (737546) ENGINE = InnoDB,\n PARTITION p201905SUB01 VALUES LESS THAN (737548) ENGINE = InnoDB,\n PARTITION p201905SUB02 VALUES LESS THAN (737550) ENGINE = InnoDB,\n PARTITION p201905SUB03 VALUES LESS THAN (737552) ENGINE = InnoDB,\n PARTITION p201905SUB04 VALUES LESS THAN (737554) ENGINE = InnoDB,\n PARTITION p201905SUB05 VALUES LESS THAN (737556) ENGINE = InnoDB,\n PARTITION p201905SUB06 VALUES LESS THAN (737558) ENGINE = InnoDB,\n PARTITION p201905SUB07 VALUES LESS THAN (737560) ENGINE = InnoDB,\n PARTITION p201905SUB08 VALUES LESS THAN (737562) ENGINE = InnoDB,\n PARTITION p201905SUB09 VALUES LESS THAN (737564) ENGINE = InnoDB,\n PARTITION p201905SUB10 VALUES LESS THAN (737566) ENGINE = InnoDB,\n PARTITION p201905SUB11 VALUES LESS THAN (737568) ENGINE = InnoDB,\n PARTITION p201905SUB12 VALUES LESS THAN (737570) ENGINE = InnoDB,\n PARTITION p201905SUB13 VALUES LESS THAN (737572) ENGINE = InnoDB,\n PARTITION p201905SUB14 VALUES LESS THAN (737574) ENGINE = InnoDB,\n PARTITION p201906SUB00 VALUES LESS THAN (737577) ENGINE = InnoDB,\n PARTITION p201906SUB01 VALUES LESS THAN (737579) ENGINE = InnoDB,\n PARTITION p201906SUB02 VALUES LESS THAN (737581) ENGINE = InnoDB,\n PARTITION p201906SUB03 VALUES LESS THAN (737583) ENGINE = InnoDB,\n PARTITION p201906SUB04 VALUES LESS THAN (737585) ENGINE = InnoDB,\n PARTITION p201906SUB05 VALUES LESS THAN (737587) ENGINE = InnoDB,\n PARTITION p201906SUB06 VALUES LESS THAN (737589) ENGINE = InnoDB,\n PARTITION p201906SUB07 VALUES LESS THAN (737591) ENGINE = InnoDB,\n PARTITION p201906SUB08 VALUES LESS THAN (737593) ENGINE = InnoDB,\n PARTITION p201906SUB09 VALUES LESS THAN (737595) ENGINE = InnoDB,\n PARTITION p201906SUB10 VALUES LESS THAN (737597) ENGINE = InnoDB,\n PARTITION p201906SUB11 VALUES LESS THAN (737599) ENGINE = InnoDB,\n PARTITION p201906SUB12 VALUES LESS THAN (737601) ENGINE = InnoDB,\n PARTITION p201906SUB13 VALUES LESS THAN (737603) ENGINE = InnoDB,\n PARTITION p201906SUB14 VALUES LESS THAN (737605) ENGINE = InnoDB,\n PARTITION p201907SUB00 VALUES LESS THAN (737607) ENGINE = InnoDB,\n PARTITION p201907SUB01 VALUES LESS THAN (737609) ENGINE = InnoDB,\n PARTITION p201907SUB02 VALUES LESS THAN (737611) ENGINE = InnoDB,\n PARTITION p201907SUB03 VALUES LESS THAN (737613) ENGINE = InnoDB,\n PARTITION p201907SUB04 VALUES LESS THAN (737615) ENGINE = InnoDB,\n PARTITION p201907SUB05 VALUES LESS THAN (737617) ENGINE = InnoDB,\n PARTITION p201907SUB06 VALUES LESS THAN (737619) ENGINE = InnoDB,\n PARTITION p201907SUB07 VALUES LESS THAN (737621) ENGINE = InnoDB,\n PARTITION p201907SUB08 VALUES LESS THAN (737623) ENGINE = InnoDB,\n PARTITION p201907SUB09 VALUES LESS THAN (737625) ENGINE = InnoDB,\n PARTITION p201907SUB10 VALUES LESS THAN (737627) ENGINE = InnoDB,\n PARTITION p201907SUB11 VALUES LESS THAN (737629) ENGINE = InnoDB,\n PARTITION p201907SUB12 VALUES LESS THAN (737631) ENGINE = InnoDB,\n PARTITION p201907SUB13 VALUES LESS THAN (737633) ENGINE = InnoDB,\n PARTITION p201907SUB14 VALUES LESS THAN (737635) ENGINE = InnoDB,\n PARTITION p201908SUB00 VALUES LESS THAN (737638) ENGINE = InnoDB,\n PARTITION p201908SUB01 VALUES LESS THAN (737640) ENGINE = InnoDB,\n PARTITION p201908SUB02 VALUES LESS THAN (737642) ENGINE = InnoDB,\n PARTITION p201908SUB03 VALUES LESS THAN (737644) ENGINE = InnoDB,\n PARTITION p201908SUB04 VALUES LESS THAN (737646) ENGINE = InnoDB,\n PARTITION p201908SUB05 VALUES LESS THAN (737648) ENGINE = InnoDB,\n PARTITION p201908SUB06 VALUES LESS THAN (737650) ENGINE = InnoDB,\n PARTITION p201908SUB07 VALUES LESS THAN (737652) ENGINE = InnoDB,\n PARTITION p201908SUB08 VALUES LESS THAN (737654) ENGINE = InnoDB,\n PARTITION p201908SUB09 VALUES LESS THAN (737656) ENGINE = InnoDB,\n PARTITION p201908SUB10 VALUES LESS THAN (737658) ENGINE = InnoDB,\n PARTITION p201908SUB11 VALUES LESS THAN (737660) ENGINE = InnoDB,\n PARTITION p201908SUB12 VALUES LESS THAN (737662) ENGINE = InnoDB,\n PARTITION p201908SUB13 VALUES LESS THAN (737664) ENGINE = InnoDB,\n PARTITION p201908SUB14 VALUES LESS THAN (737666) ENGINE = InnoDB,\n PARTITION p201909SUB00 VALUES LESS THAN (737669) ENGINE = InnoDB,\n PARTITION p201909SUB01 VALUES LESS THAN (737671) ENGINE = InnoDB,\n PARTITION p201909SUB02 VALUES LESS THAN (737673) ENGINE = InnoDB,\n PARTITION p201909SUB03 VALUES LESS THAN (737675) ENGINE = InnoDB,\n PARTITION p201909SUB04 VALUES LESS THAN (737677) ENGINE = InnoDB,\n PARTITION p201909SUB05 VALUES LESS THAN (737679) ENGINE = InnoDB,\n PARTITION p201909SUB06 VALUES LESS THAN (737681) ENGINE = InnoDB,\n PARTITION p201909SUB07 VALUES LESS THAN (737683) ENGINE = InnoDB,\n PARTITION p201909SUB08 VALUES LESS THAN (737685) ENGINE = InnoDB,\n PARTITION p201909SUB09 VALUES LESS THAN (737687) ENGINE = InnoDB,\n PARTITION p201909SUB10 VALUES LESS THAN (737689) ENGINE = InnoDB,\n PARTITION p201909SUB11 VALUES LESS THAN (737691) ENGINE = InnoDB,\n PARTITION p201909SUB12 VALUES LESS THAN (737693) ENGINE = InnoDB,\n PARTITION p201909SUB13 VALUES LESS THAN (737695) ENGINE = InnoDB,\n PARTITION p201909SUB14 VALUES LESS THAN (737697) ENGINE = InnoDB,\n PARTITION p201910SUB00 VALUES LESS THAN (737699) ENGINE = InnoDB,\n PARTITION p201910SUB01 VALUES LESS THAN (737701) ENGINE = InnoDB,\n PARTITION p201910SUB02 VALUES LESS THAN (737703) ENGINE = InnoDB,\n PARTITION p201910SUB03 VALUES LESS THAN (737705) ENGINE = InnoDB,\n PARTITION p201910SUB04 VALUES LESS THAN (737707) ENGINE = InnoDB,\n PARTITION p201910SUB05 VALUES LESS THAN (737709) ENGINE = InnoDB,\n PARTITION p201910SUB06 VALUES LESS THAN (737711) ENGINE = InnoDB,\n PARTITION p201910SUB07 VALUES LESS THAN (737713) ENGINE = InnoDB,\n PARTITION p201910SUB08 VALUES LESS THAN (737715) ENGINE = InnoDB,\n PARTITION p201910SUB09 VALUES LESS THAN (737717) ENGINE = InnoDB,\n PARTITION p201910SUB10 VALUES LESS THAN (737719) ENGINE = InnoDB,\n PARTITION p201910SUB11 VALUES LESS THAN (737721) ENGINE = InnoDB,\n PARTITION p201910SUB12 VALUES LESS THAN (737723) ENGINE = InnoDB,\n PARTITION p201910SUB13 VALUES LESS THAN (737725) ENGINE = InnoDB,\n PARTITION p201910SUB14 VALUES LESS THAN (737727) ENGINE = InnoDB,\n PARTITION p201911SUB00 VALUES LESS THAN (737730) ENGINE = InnoDB,\n PARTITION p201911SUB01 VALUES LESS THAN (737732) ENGINE = InnoDB,\n PARTITION p201911SUB02 VALUES LESS THAN (737734) ENGINE = InnoDB,\n PARTITION p201911SUB03 VALUES LESS THAN (737736) ENGINE = InnoDB,\n PARTITION p201911SUB04 VALUES LESS THAN (737738) ENGINE = InnoDB,\n PARTITION p201911SUB05 VALUES LESS THAN (737740) ENGINE = InnoDB,\n PARTITION p201911SUB06 VALUES LESS THAN (737742) ENGINE = InnoDB,\n PARTITION p201911SUB07 VALUES LESS THAN (737744) ENGINE = InnoDB,\n PARTITION p201911SUB08 VALUES LESS THAN (737746) ENGINE = InnoDB,\n PARTITION p201911SUB09 VALUES LESS THAN (737748) ENGINE = InnoDB,\n PARTITION p201911SUB10 VALUES LESS THAN (737750) ENGINE = InnoDB,\n PARTITION p201911SUB11 VALUES LESS THAN (737752) ENGINE = InnoDB,\n PARTITION p201911SUB12 VALUES LESS THAN (737754) ENGINE = InnoDB,\n PARTITION p201911SUB13 VALUES LESS THAN (737756) ENGINE = InnoDB,\n PARTITION p201911SUB14 VALUES LESS THAN (737758) ENGINE = InnoDB,\n PARTITION p201912SUB00 VALUES LESS THAN (737760) ENGINE = InnoDB,\n PARTITION p201912SUB01 VALUES LESS THAN (737762) ENGINE = InnoDB,\n PARTITION p201912SUB02 VALUES LESS THAN (737764) ENGINE = InnoDB,\n PARTITION p201912SUB03 VALUES LESS THAN (737766) ENGINE = InnoDB,\n PARTITION p201912SUB04 VALUES LESS THAN (737768) ENGINE = InnoDB,\n PARTITION p201912SUB05 VALUES LESS THAN (737770) ENGINE = InnoDB,\n PARTITION p201912SUB06 VALUES LESS THAN (737772) ENGINE = InnoDB,\n PARTITION p201912SUB07 VALUES LESS THAN (737774) ENGINE = InnoDB,\n PARTITION p201912SUB08 VALUES LESS THAN (737776) ENGINE = InnoDB,\n PARTITION p201912SUB09 VALUES LESS THAN (737778) ENGINE = InnoDB,\n PARTITION p201912SUB10 VALUES LESS THAN (737780) ENGINE = InnoDB,\n PARTITION p201912SUB11 VALUES LESS THAN (737782) ENGINE = InnoDB,\n PARTITION p201912SUB12 VALUES LESS THAN (737784) ENGINE = InnoDB,\n PARTITION p201912SUB13 VALUES LESS THAN (737786) ENGINE = InnoDB,\n PARTITION p201912SUB14 VALUES LESS THAN (737788) ENGINE = InnoDB,\n PARTITION p202001SUB00 VALUES LESS THAN (737791) ENGINE = InnoDB,\n PARTITION p202001SUB01 VALUES LESS THAN (737793) ENGINE = InnoDB,\n PARTITION p202001SUB02 VALUES LESS THAN (737795) ENGINE = InnoDB,\n PARTITION p202001SUB03 VALUES LESS THAN (737797) ENGINE = InnoDB,\n PARTITION p202001SUB04 VALUES LESS THAN (737799) ENGINE = InnoDB,\n PARTITION p202001SUB05 VALUES LESS THAN (737801) ENGINE = InnoDB,\n PARTITION p202001SUB06 VALUES LESS THAN (737803) ENGINE = InnoDB,\n PARTITION p202001SUB07 VALUES LESS THAN (737805) ENGINE = InnoDB,\n PARTITION p202001SUB08 VALUES LESS THAN (737807) ENGINE = InnoDB,\n PARTITION p202001SUB09 VALUES LESS THAN (737809) ENGINE = InnoDB,\n PARTITION p202001SUB10 VALUES LESS THAN (737811) ENGINE = InnoDB,\n PARTITION p202001SUB11 VALUES LESS THAN (737813) ENGINE = InnoDB,\n PARTITION p202001SUB12 VALUES LESS THAN (737815) ENGINE = InnoDB,\n PARTITION p202001SUB13 VALUES LESS THAN (737817) ENGINE = InnoDB,\n PARTITION p202001SUB14 VALUES LESS THAN (737819) ENGINE = InnoDB,\n PARTITION p202002SUB00 VALUES LESS THAN (737822) ENGINE = InnoDB,\n PARTITION p202002SUB01 VALUES LESS THAN (737824) ENGINE = InnoDB,\n PARTITION p202002SUB02 VALUES LESS THAN (737826) ENGINE = InnoDB,\n PARTITION p202002SUB03 VALUES LESS THAN (737828) ENGINE = InnoDB,\n PARTITION p202002SUB04 VALUES LESS THAN (737830) ENGINE = InnoDB,\n PARTITION p202002SUB05 VALUES LESS THAN (737832) ENGINE = InnoDB,\n PARTITION p202002SUB06 VALUES LESS THAN (737834) ENGINE = InnoDB,\n PARTITION p202002SUB07 VALUES LESS THAN (737836) ENGINE = InnoDB,\n PARTITION p202002SUB08 VALUES LESS THAN (737838) ENGINE = InnoDB,\n PARTITION p202002SUB09 VALUES LESS THAN (737840) ENGINE = InnoDB,\n PARTITION p202002SUB10 VALUES LESS THAN (737842) ENGINE = InnoDB,\n PARTITION p202002SUB11 VALUES LESS THAN (737844) ENGINE = InnoDB,\n PARTITION p202002SUB12 VALUES LESS THAN (737846) ENGINE = InnoDB,\n PARTITION p202002SUB13 VALUES LESS THAN (737848) ENGINE = InnoDB,\n PARTITION p202003SUB00 VALUES LESS THAN (737851) ENGINE = InnoDB,\n PARTITION p202003SUB01 VALUES LESS THAN (737853) ENGINE = InnoDB,\n PARTITION p202003SUB02 VALUES LESS THAN (737855) ENGINE = InnoDB,\n PARTITION p202003SUB03 VALUES LESS THAN (737857) ENGINE = InnoDB,\n PARTITION p202003SUB04 VALUES LESS THAN (737859) ENGINE = InnoDB,\n PARTITION p202003SUB05 VALUES LESS THAN (737861) ENGINE = InnoDB,\n PARTITION p202003SUB06 VALUES LESS THAN (737863) ENGINE = InnoDB,\n PARTITION p202003SUB07 VALUES LESS THAN (737865) ENGINE = InnoDB,\n PARTITION p202003SUB08 VALUES LESS THAN (737867) ENGINE = InnoDB,\n PARTITION p202003SUB09 VALUES LESS THAN (737869) ENGINE = InnoDB,\n PARTITION p202003SUB10 VALUES LESS THAN (737871) ENGINE = InnoDB,\n PARTITION p202003SUB11 VALUES LESS THAN (737873) ENGINE = InnoDB,\n PARTITION p202003SUB12 VALUES LESS THAN (737875) ENGINE = InnoDB,\n PARTITION p202003SUB13 VALUES LESS THAN (737877) ENGINE = InnoDB,\n PARTITION p202003SUB14 VALUES LESS THAN (737879) ENGINE = InnoDB,\n PARTITION p202004SUB00 VALUES LESS THAN (737882) ENGINE = InnoDB,\n PARTITION p202004SUB01 VALUES LESS THAN (737884) ENGINE = InnoDB,\n PARTITION p202004SUB02 VALUES LESS THAN (737886) ENGINE = InnoDB,\n PARTITION p202004SUB03 VALUES LESS THAN (737888) ENGINE = InnoDB,\n PARTITION p202004SUB04 VALUES LESS THAN (737890) ENGINE = InnoDB,\n PARTITION p202004SUB05 VALUES LESS THAN (737892) ENGINE = InnoDB,\n PARTITION p202004SUB06 VALUES LESS THAN (737894) ENGINE = InnoDB,\n PARTITION p202004SUB07 VALUES LESS THAN (737896) ENGINE = InnoDB,\n PARTITION p202004SUB08 VALUES LESS THAN (737898) ENGINE = InnoDB,\n PARTITION p202004SUB09 VALUES LESS THAN (737900) ENGINE = InnoDB,\n PARTITION p202004SUB10 VALUES LESS THAN (737902) ENGINE = InnoDB,\n PARTITION p202004SUB11 VALUES LESS THAN (737904) ENGINE = InnoDB,\n PARTITION p202004SUB12 VALUES LESS THAN (737906) ENGINE = InnoDB,\n PARTITION p202004SUB13 VALUES LESS THAN (737908) ENGINE = InnoDB,\n PARTITION p202004SUB14 VALUES LESS THAN (737910) ENGINE = InnoDB,\n PARTITION p202005SUB00 VALUES LESS THAN (737912) ENGINE = InnoDB,\n PARTITION p202005SUB01 VALUES LESS THAN (737914) ENGINE = InnoDB,\n PARTITION p202005SUB02 VALUES LESS THAN (737916) ENGINE = InnoDB,\n PARTITION p202005SUB03 VALUES LESS THAN (737918) ENGINE = InnoDB,\n PARTITION p202005SUB04 VALUES LESS THAN (737920) ENGINE = InnoDB,\n PARTITION p202005SUB05 VALUES LESS THAN (737922) ENGINE = InnoDB,\n PARTITION p202005SUB06 VALUES LESS THAN (737924) ENGINE = InnoDB,\n PARTITION p202005SUB07 VALUES LESS THAN (737926) ENGINE = InnoDB,\n PARTITION p202005SUB08 VALUES LESS THAN (737928) ENGINE = InnoDB,\n PARTITION p202005SUB09 VALUES LESS THAN (737930) ENGINE = InnoDB,\n PARTITION p202005SUB10 VALUES LESS THAN (737932) ENGINE = InnoDB,\n PARTITION p202005SUB11 VALUES LESS THAN (737934) ENGINE = InnoDB,\n PARTITION p202005SUB12 VALUES LESS THAN (737936) ENGINE = InnoDB,\n PARTITION p202005SUB13 VALUES LESS THAN (737938) ENGINE = InnoDB,\n PARTITION p202005SUB14 VALUES LESS THAN (737940) ENGINE = InnoDB,\n PARTITION p202006SUB00 VALUES LESS THAN (737943) ENGINE = InnoDB,\n PARTITION p202006SUB01 VALUES LESS THAN (737945) ENGINE = InnoDB,\n PARTITION p202006SUB02 VALUES LESS THAN (737947) ENGINE = InnoDB,\n PARTITION p202006SUB03 VALUES LESS THAN (737949) ENGINE = InnoDB,\n PARTITION p202006SUB04 VALUES LESS THAN (737951) ENGINE = InnoDB,\n PARTITION p202006SUB05 VALUES LESS THAN (737953) ENGINE = InnoDB,\n PARTITION p202006SUB06 VALUES LESS THAN (737955) ENGINE = InnoDB,\n PARTITION p202006SUB07 VALUES LESS THAN (737957) ENGINE = InnoDB,\n PARTITION p202006SUB08 VALUES LESS THAN (737959) ENGINE = InnoDB,\n PARTITION p202006SUB09 VALUES LESS THAN (737961) ENGINE = InnoDB,\n PARTITION p202006SUB10 VALUES LESS THAN (737963) ENGINE = InnoDB,\n PARTITION p202006SUB11 VALUES LESS THAN (737965) ENGINE = InnoDB,\n PARTITION p202006SUB12 VALUES LESS THAN (737967) ENGINE = InnoDB,\n PARTITION p202006SUB13 VALUES LESS THAN (737969) ENGINE = InnoDB,\n PARTITION p202006SUB14 VALUES LESS THAN (737971) ENGINE = InnoDB,\n PARTITION p202007SUB00 VALUES LESS THAN (737973) ENGINE = InnoDB,\n PARTITION p202007SUB01 VALUES LESS THAN (737975) ENGINE = InnoDB,\n PARTITION p202007SUB02 VALUES LESS THAN (737977) ENGINE = InnoDB,\n PARTITION p202007SUB03 VALUES LESS THAN (737979) ENGINE = InnoDB,\n PARTITION p202007SUB04 VALUES LESS THAN (737981) ENGINE = InnoDB,\n PARTITION p202007SUB05 VALUES LESS THAN (737983) ENGINE = InnoDB,\n PARTITION p202007SUB06 VALUES LESS THAN (737985) ENGINE = InnoDB,\n PARTITION p202007SUB07 VALUES LESS THAN (737987) ENGINE = InnoDB,\n PARTITION p202007SUB08 VALUES LESS THAN (737989) ENGINE = InnoDB,\n PARTITION p202007SUB09 VALUES LESS THAN (737991) ENGINE = InnoDB,\n PARTITION p202007SUB10 VALUES LESS THAN (737993) ENGINE = InnoDB,\n PARTITION p202007SUB11 VALUES LESS THAN (737995) ENGINE = InnoDB,\n PARTITION p202007SUB12 VALUES LESS THAN (737997) ENGINE = InnoDB,\n PARTITION p202007SUB13 VALUES LESS THAN (737999) ENGINE = InnoDB,\n PARTITION p202007SUB14 VALUES LESS THAN (738001) ENGINE = InnoDB,\n PARTITION p202008SUB00 VALUES LESS THAN (738004) ENGINE = InnoDB,\n PARTITION p202008SUB01 VALUES LESS THAN (738006) ENGINE = InnoDB,\n PARTITION p202008SUB02 VALUES LESS THAN (738008) ENGINE = InnoDB,\n PARTITION p202008SUB03 VALUES LESS THAN (738010) ENGINE = InnoDB,\n PARTITION p202008SUB04 VALUES LESS THAN (738012) ENGINE = InnoDB,\n PARTITION p202008SUB05 VALUES LESS THAN (738014) ENGINE = InnoDB,\n PARTITION p202008SUB06 VALUES LESS THAN (738016) ENGINE = InnoDB,\n PARTITION p202008SUB07 VALUES LESS THAN (738018) ENGINE = InnoDB,\n PARTITION p202008SUB08 VALUES LESS THAN (738020) ENGINE = InnoDB,\n PARTITION p202008SUB09 VALUES LESS THAN (738022) ENGINE = InnoDB,\n PARTITION p202008SUB10 VALUES LESS THAN (738024) ENGINE = InnoDB,\n PARTITION p202008SUB11 VALUES LESS THAN (738026) ENGINE = InnoDB,\n PARTITION p202008SUB12 VALUES LESS THAN (738028) ENGINE = InnoDB,\n PARTITION p202008SUB13 VALUES LESS THAN (738030) ENGINE = InnoDB,\n PARTITION p202008SUB14 VALUES LESS THAN (738032) ENGINE = InnoDB,\n PARTITION p202009SUB00 VALUES LESS THAN (738035) ENGINE = InnoDB,\n PARTITION p202009SUB01 VALUES LESS THAN (738037) ENGINE = InnoDB,\n PARTITION p202009SUB02 VALUES LESS THAN (738039) ENGINE = InnoDB,\n PARTITION p202009SUB03 VALUES LESS THAN (738041) ENGINE = InnoDB,\n PARTITION p202009SUB04 VALUES LESS THAN (738043) ENGINE = InnoDB,\n PARTITION p202009SUB05 VALUES LESS THAN (738045) ENGINE = InnoDB,\n PARTITION p202009SUB06 VALUES LESS THAN (738047) ENGINE = InnoDB,\n PARTITION p202009SUB07 VALUES LESS THAN (738049) ENGINE = InnoDB,\n PARTITION p202009SUB08 VALUES LESS THAN (738051) ENGINE = InnoDB,\n PARTITION p202009SUB09 VALUES LESS THAN (738053) ENGINE = InnoDB,\n PARTITION p202009SUB10 VALUES LESS THAN (738055) ENGINE = InnoDB,\n PARTITION p202009SUB11 VALUES LESS THAN (738057) ENGINE = InnoDB,\n PARTITION p202009SUB12 VALUES LESS THAN (738059) ENGINE = InnoDB,\n PARTITION p202009SUB13 VALUES LESS THAN (738061) ENGINE = InnoDB,\n PARTITION p202009SUB14 VALUES LESS THAN (738063) ENGINE = InnoDB,\n PARTITION p202010SUB00 VALUES LESS THAN (738065) ENGINE = InnoDB,\n PARTITION p202010SUB01 VALUES LESS THAN (738067) ENGINE = InnoDB,\n PARTITION p202010SUB02 VALUES LESS THAN (738069) ENGINE = InnoDB,\n PARTITION p202010SUB03 VALUES LESS THAN (738071) ENGINE = InnoDB,\n PARTITION p202010SUB04 VALUES LESS THAN (738073) ENGINE = InnoDB,\n PARTITION p202010SUB05 VALUES LESS THAN (738075) ENGINE = InnoDB,\n PARTITION p202010SUB06 VALUES LESS THAN (738077) ENGINE = InnoDB,\n PARTITION p202010SUB07 VALUES LESS THAN (738079) ENGINE = InnoDB,\n PARTITION p202010SUB08 VALUES LESS THAN (738081) ENGINE = InnoDB,\n PARTITION p202010SUB09 VALUES LESS THAN (738083) ENGINE = InnoDB,\n PARTITION p202010SUB10 VALUES LESS THAN (738085) ENGINE = InnoDB,\n PARTITION p202010SUB11 VALUES LESS THAN (738087) ENGINE = InnoDB,\n PARTITION p202010SUB12 VALUES LESS THAN (738089) ENGINE = InnoDB,\n PARTITION p202010SUB13 VALUES LESS THAN (738091) ENGINE = InnoDB,\n PARTITION p202010SUB14 VALUES LESS THAN (738093) ENGINE = InnoDB,\n PARTITION p202011SUB00 VALUES LESS THAN (738096) ENGINE = InnoDB,\n PARTITION p202011SUB01 VALUES LESS THAN (738098) ENGINE = InnoDB,\n PARTITION p202011SUB02 VALUES LESS THAN (738100) ENGINE = InnoDB,\n PARTITION p202011SUB03 VALUES LESS THAN (738102) ENGINE = InnoDB,\n PARTITION p202011SUB04 VALUES LESS THAN (738104) ENGINE = InnoDB,\n PARTITION p202011SUB05 VALUES LESS THAN (738106) ENGINE = InnoDB,\n PARTITION p202011SUB06 VALUES LESS THAN (738108) ENGINE = InnoDB,\n PARTITION p202011SUB07 VALUES LESS THAN (738110) ENGINE = InnoDB,\n PARTITION p202011SUB08 VALUES LESS THAN (738112) ENGINE = InnoDB,\n PARTITION p202011SUB09 VALUES LESS THAN (738114) ENGINE = InnoDB,\n PARTITION p202011SUB10 VALUES LESS THAN (738116) ENGINE = InnoDB,\n PARTITION p202011SUB11 VALUES LESS THAN (738118) ENGINE = InnoDB,\n PARTITION p202011SUB12 VALUES LESS THAN (738120) ENGINE = InnoDB,\n PARTITION p202011SUB13 VALUES LESS THAN (738122) ENGINE = InnoDB,\n PARTITION p202011SUB14 VALUES LESS THAN (738124) ENGINE = InnoDB,\n PARTITION p202012SUB00 VALUES LESS THAN (738126) ENGINE = InnoDB,\n PARTITION p202012SUB01 VALUES LESS THAN (738128) ENGINE = InnoDB,\n PARTITION p202012SUB02 VALUES LESS THAN (738130) ENGINE = InnoDB,\n PARTITION p202012SUB03 VALUES LESS THAN (738132) ENGINE = InnoDB,\n PARTITION p202012SUB04 VALUES LESS THAN (738134) ENGINE = InnoDB,\n PARTITION p202012SUB05 VALUES LESS THAN (738136) ENGINE = InnoDB,\n PARTITION p202012SUB06 VALUES LESS THAN (738138) ENGINE = InnoDB,\n PARTITION p202012SUB07 VALUES LESS THAN (738140) ENGINE = InnoDB,\n PARTITION p202012SUB08 VALUES LESS THAN (738142) ENGINE = InnoDB,\n PARTITION p202012SUB09 VALUES LESS THAN (738144) ENGINE = InnoDB,\n PARTITION p202012SUB10 VALUES LESS THAN (738146) ENGINE = InnoDB,\n PARTITION p202012SUB11 VALUES LESS THAN (738148) ENGINE = InnoDB,\n PARTITION p202012SUB12 VALUES LESS THAN (738150) ENGINE = InnoDB,\n PARTITION p202012SUB13 VALUES LESS THAN (738152) ENGINE = InnoDB,\n PARTITION p202012SUB14 VALUES LESS THAN (738154) ENGINE = InnoDB,\n PARTITION p202101SUB00 VALUES LESS THAN (738157) ENGINE = InnoDB,\n PARTITION p202101SUB01 VALUES LESS THAN (738159) ENGINE = InnoDB,\n PARTITION p202101SUB02 VALUES LESS THAN (738161) ENGINE = InnoDB,\n PARTITION p202101SUB03 VALUES LESS THAN (738163) ENGINE = InnoDB,\n PARTITION p202101SUB04 VALUES LESS THAN (738165) ENGINE = InnoDB,\n PARTITION p202101SUB05 VALUES LESS THAN (738167) ENGINE = InnoDB,\n PARTITION p202101SUB06 VALUES LESS THAN (738169) ENGINE = InnoDB,\n PARTITION p202101SUB07 VALUES LESS THAN (738171) ENGINE = InnoDB,\n PARTITION p202101SUB08 VALUES LESS THAN (738173) ENGINE = InnoDB,\n PARTITION p202101SUB09 VALUES LESS THAN (738175) ENGINE = InnoDB,\n PARTITION p202101SUB10 VALUES LESS THAN (738177) ENGINE = InnoDB,\n PARTITION p202101SUB11 VALUES LESS THAN (738179) ENGINE = InnoDB,\n PARTITION p202101SUB12 VALUES LESS THAN (738181) ENGINE = InnoDB,\n PARTITION p202101SUB13 VALUES LESS THAN (738183) ENGINE = InnoDB,\n PARTITION p202101SUB14 VALUES LESS THAN (738185) ENGINE = InnoDB,\n PARTITION p202102SUB00 VALUES LESS THAN (738188) ENGINE = InnoDB,\n PARTITION p202102SUB01 VALUES LESS THAN (738190) ENGINE = InnoDB,\n PARTITION p202102SUB02 VALUES LESS THAN (738192) ENGINE = InnoDB,\n PARTITION p202102SUB03 VALUES LESS THAN (738194) ENGINE = InnoDB,\n PARTITION p202102SUB04 VALUES LESS THAN (738196) ENGINE = InnoDB,\n PARTITION p202102SUB05 VALUES LESS THAN (738198) ENGINE = InnoDB,\n PARTITION p202102SUB06 VALUES LESS THAN (738200) ENGINE = InnoDB,\n PARTITION p202102SUB07 VALUES LESS THAN (738202) ENGINE = InnoDB,\n PARTITION p202102SUB08 VALUES LESS THAN (738204) ENGINE = InnoDB,\n PARTITION p202102SUB09 VALUES LESS THAN (738206) ENGINE = InnoDB,\n PARTITION p202102SUB10 VALUES LESS THAN (738208) ENGINE = InnoDB,\n PARTITION p202102SUB11 VALUES LESS THAN (738210) ENGINE = InnoDB,\n PARTITION p202102SUB12 VALUES LESS THAN (738212) ENGINE = InnoDB,\n PARTITION p202102SUB13 VALUES LESS THAN (738214) ENGINE = InnoDB,\n PARTITION p202103SUB00 VALUES LESS THAN (738216) ENGINE = InnoDB,\n PARTITION p202103SUB01 VALUES LESS THAN (738218) ENGINE = InnoDB,\n PARTITION p202103SUB02 VALUES LESS THAN (738220) ENGINE = InnoDB,\n PARTITION p202103SUB03 VALUES LESS THAN (738222) ENGINE = InnoDB,\n PARTITION p202103SUB04 VALUES LESS THAN (738224) ENGINE = InnoDB,\n PARTITION p202103SUB05 VALUES LESS THAN (738226) ENGINE = InnoDB,\n PARTITION p202103SUB06 VALUES LESS THAN (738228) ENGINE = InnoDB,\n PARTITION p202103SUB07 VALUES LESS THAN (738230) ENGINE = InnoDB,\n PARTITION p202103SUB08 VALUES LESS THAN (738232) ENGINE = InnoDB,\n PARTITION p202103SUB09 VALUES LESS THAN (738234) ENGINE = InnoDB,\n PARTITION p202103SUB10 VALUES LESS THAN (738236) ENGINE = InnoDB,\n PARTITION p202103SUB11 VALUES LESS THAN (738238) ENGINE = InnoDB,\n PARTITION p202103SUB12 VALUES LESS THAN (738240) ENGINE = InnoDB,\n PARTITION p202103SUB13 VALUES LESS THAN (738242) ENGINE = InnoDB,\n PARTITION p202103SUB14 VALUES LESS THAN (738244) ENGINE = InnoDB,\n PARTITION p202104SUB00 VALUES LESS THAN (738247) ENGINE = InnoDB,\n PARTITION p202104SUB01 VALUES LESS THAN (738249) ENGINE = InnoDB,\n PARTITION p202104SUB02 VALUES LESS THAN (738251) ENGINE = InnoDB,\n PARTITION p202104SUB03 VALUES LESS THAN (738253) ENGINE = InnoDB,\n PARTITION p202104SUB04 VALUES LESS THAN (738255) ENGINE = InnoDB,\n PARTITION p202104SUB05 VALUES LESS THAN (738257) ENGINE = InnoDB,\n PARTITION p202104SUB06 VALUES LESS THAN (738259) ENGINE = InnoDB,\n PARTITION p202104SUB07 VALUES LESS THAN (738261) ENGINE = InnoDB,\n PARTITION p202104SUB08 VALUES LESS THAN (738263) ENGINE = InnoDB,\n PARTITION p202104SUB09 VALUES LESS THAN (738265) ENGINE = InnoDB,\n PARTITION p202104SUB10 VALUES LESS THAN (738267) ENGINE = InnoDB,\n PARTITION p202104SUB11 VALUES LESS THAN (738269) ENGINE = InnoDB,\n PARTITION p202104SUB12 VALUES LESS THAN (738271) ENGINE = InnoDB,\n PARTITION p202104SUB13 VALUES LESS THAN (738273) ENGINE = InnoDB,\n PARTITION p202104SUB14 VALUES LESS THAN (738275) ENGINE = InnoDB,\n PARTITION p202105SUB00 VALUES LESS THAN (738277) ENGINE = InnoDB,\n PARTITION p202105SUB01 VALUES LESS THAN (738279) ENGINE = InnoDB,\n PARTITION p202105SUB02 VALUES LESS THAN (738281) ENGINE = InnoDB,\n PARTITION p202105SUB03 VALUES LESS THAN (738283) ENGINE = InnoDB,\n PARTITION p202105SUB04 VALUES LESS THAN (738285) ENGINE = InnoDB,\n PARTITION p202105SUB05 VALUES LESS THAN (738287) ENGINE = InnoDB,\n PARTITION p202105SUB06 VALUES LESS THAN (738289) ENGINE = InnoDB,\n PARTITION p202105SUB07 VALUES LESS THAN (738291) ENGINE = InnoDB,\n PARTITION p202105SUB08 VALUES LESS THAN (738293) ENGINE = InnoDB,\n PARTITION p202105SUB09 VALUES LESS THAN (738295) ENGINE = InnoDB,\n PARTITION p202105SUB10 VALUES LESS THAN (738297) ENGINE = InnoDB,\n PARTITION p202105SUB11 VALUES LESS THAN (738299) ENGINE = InnoDB,\n PARTITION p202105SUB12 VALUES LESS THAN (738301) ENGINE = InnoDB,\n PARTITION p202105SUB13 VALUES LESS THAN (738303) ENGINE = InnoDB,\n PARTITION p202105SUB14 VALUES LESS THAN (738305) ENGINE = InnoDB,\n PARTITION p202106SUB00 VALUES LESS THAN (738308) ENGINE = InnoDB,\n PARTITION p202106SUB01 VALUES LESS THAN (738310) ENGINE = InnoDB,\n PARTITION p202106SUB02 VALUES LESS THAN (738312) ENGINE = InnoDB,\n PARTITION p202106SUB03 VALUES LESS THAN (738314) ENGINE = InnoDB,\n PARTITION p202106SUB04 VALUES LESS THAN (738316) ENGINE = InnoDB,\n PARTITION p202106SUB05 VALUES LESS THAN (738318) ENGINE = InnoDB,\n PARTITION p202106SUB06 VALUES LESS THAN (738320) ENGINE = InnoDB,\n PARTITION p202106SUB07 VALUES LESS THAN (738322) ENGINE = InnoDB,\n PARTITION p202106SUB08 VALUES LESS THAN (738324) ENGINE = InnoDB,\n PARTITION p202106SUB09 VALUES LESS THAN (738326) ENGINE = InnoDB,\n PARTITION p202106SUB10 VALUES LESS THAN (738328) ENGINE = InnoDB,\n PARTITION p202106SUB11 VALUES LESS THAN (738330) ENGINE = InnoDB,\n PARTITION p202106SUB12 VALUES LESS THAN (738332) ENGINE = InnoDB,\n PARTITION p202106SUB13 VALUES LESS THAN (738334) ENGINE = InnoDB,\n PARTITION p202106SUB14 VALUES LESS THAN (738336) ENGINE = InnoDB,\n PARTITION p202107SUB00 VALUES LESS THAN (738338) ENGINE = InnoDB,\n PARTITION p202107SUB01 VALUES LESS THAN (738340) ENGINE = InnoDB,\n PARTITION p202107SUB02 VALUES LESS THAN (738342) ENGINE = InnoDB,\n PARTITION p202107SUB03 VALUES LESS THAN (738344) ENGINE = InnoDB,\n PARTITION p202107SUB04 VALUES LESS THAN (738346) ENGINE = InnoDB,\n PARTITION p202107SUB05 VALUES LESS THAN (738348) ENGINE = InnoDB,\n PARTITION p202107SUB06 VALUES LESS THAN (738350) ENGINE = InnoDB,\n PARTITION p202107SUB07 VALUES LESS THAN (738352) ENGINE = InnoDB,\n PARTITION p202107SUB08 VALUES LESS THAN (738354) ENGINE = InnoDB,\n PARTITION p202107SUB09 VALUES LESS THAN (738356) ENGINE = InnoDB,\n PARTITION p202107SUB10 VALUES LESS THAN (738358) ENGINE = InnoDB,\n PARTITION p202107SUB11 VALUES LESS THAN (738360) ENGINE = InnoDB,\n PARTITION p202107SUB12 VALUES LESS THAN (738362) ENGINE = InnoDB,\n PARTITION p202107SUB13 VALUES LESS THAN (738364) ENGINE = InnoDB,\n PARTITION p202107SUB14 VALUES LESS THAN (738366) ENGINE = InnoDB,\n PARTITION p202108SUB00 VALUES LESS THAN (738369) ENGINE = InnoDB,\n PARTITION p202108SUB01 VALUES LESS THAN (738371) ENGINE = InnoDB,\n PARTITION p202108SUB02 VALUES LESS THAN (738373) ENGINE = InnoDB,\n PARTITION p202108SUB03 VALUES LESS THAN (738375) ENGINE = InnoDB,\n PARTITION p202108SUB04 VALUES LESS THAN (738377) ENGINE = InnoDB,\n PARTITION p202108SUB05 VALUES LESS THAN (738379) ENGINE = InnoDB,\n PARTITION p202108SUB06 VALUES LESS THAN (738381) ENGINE = InnoDB,\n PARTITION p202108SUB07 VALUES LESS THAN (738383) ENGINE = InnoDB,\n PARTITION p202108SUB08 VALUES LESS THAN (738385) ENGINE = InnoDB,\n PARTITION p202108SUB09 VALUES LESS THAN (738387) ENGINE = InnoDB,\n PARTITION p202108SUB10 VALUES LESS THAN (738389) ENGINE = InnoDB,\n PARTITION p202108SUB11 VALUES LESS THAN (738391) ENGINE = InnoDB,\n PARTITION p202108SUB12 VALUES LESS THAN (738393) ENGINE = InnoDB,\n PARTITION p202108SUB13 VALUES LESS THAN (738395) ENGINE = InnoDB,\n PARTITION p202108SUB14 VALUES LESS THAN (738397) ENGINE = InnoDB,\n PARTITION p202109SUB00 VALUES LESS THAN (738400) ENGINE = InnoDB,\n PARTITION p202109SUB01 VALUES LESS THAN (738402) ENGINE = InnoDB,\n PARTITION p202109SUB02 VALUES LESS THAN (738404) ENGINE = InnoDB,\n PARTITION p202109SUB03 VALUES LESS THAN (738406) ENGINE = InnoDB,\n PARTITION p202109SUB04 VALUES LESS THAN (738408) ENGINE = InnoDB,\n PARTITION p202109SUB05 VALUES LESS THAN (738410) ENGINE = InnoDB,\n PARTITION p202109SUB06 VALUES LESS THAN (738412) ENGINE = InnoDB,\n PARTITION p202109SUB07 VALUES LESS THAN (738414) ENGINE = InnoDB,\n PARTITION p202109SUB08 VALUES LESS THAN (738416) ENGINE = InnoDB,\n PARTITION p202109SUB09 VALUES LESS THAN (738418) ENGINE = InnoDB,\n PARTITION p202109SUB10 VALUES LESS THAN (738420) ENGINE = InnoDB,\n PARTITION p202109SUB11 VALUES LESS THAN (738422) ENGINE = InnoDB,\n PARTITION p202109SUB12 VALUES LESS THAN (738424) ENGINE = InnoDB,\n PARTITION p202109SUB13 VALUES LESS THAN (738426) ENGINE = InnoDB,\n PARTITION p202109SUB14 VALUES LESS THAN (738428) ENGINE = InnoDB,\n PARTITION p202110SUB00 VALUES LESS THAN (738430) ENGINE = InnoDB,\n PARTITION p202110SUB01 VALUES LESS THAN (738432) ENGINE = InnoDB,\n PARTITION p202110SUB02 VALUES LESS THAN (738434) ENGINE = InnoDB,\n PARTITION p202110SUB03 VALUES LESS THAN (738436) ENGINE = InnoDB,\n PARTITION p202110SUB04 VALUES LESS THAN (738438) ENGINE = InnoDB,\n PARTITION p202110SUB05 VALUES LESS THAN (738440) ENGINE = InnoDB,\n PARTITION p202110SUB06 VALUES LESS THAN (738442) ENGINE = InnoDB,\n PARTITION p202110SUB07 VALUES LESS THAN (738444) ENGINE = InnoDB,\n PARTITION p202110SUB08 VALUES LESS THAN (738446) ENGINE = InnoDB,\n PARTITION p202110SUB09 VALUES LESS THAN (738448) ENGINE = InnoDB,\n PARTITION p202110SUB10 VALUES LESS THAN (738450) ENGINE = InnoDB,\n PARTITION p202110SUB11 VALUES LESS THAN (738452) ENGINE = InnoDB,\n PARTITION p202110SUB12 VALUES LESS THAN (738454) ENGINE = InnoDB,\n PARTITION p202110SUB13 VALUES LESS THAN (738456) ENGINE = InnoDB,\n PARTITION p202110SUB14 VALUES LESS THAN (738458) ENGINE = InnoDB,\n PARTITION p202111SUB00 VALUES LESS THAN (738461) ENGINE = InnoDB,\n PARTITION p202111SUB01 VALUES LESS THAN (738463) ENGINE = InnoDB,\n PARTITION p202111SUB02 VALUES LESS THAN (738465) ENGINE = InnoDB,\n PARTITION p202111SUB03 VALUES LESS THAN (738467) ENGINE = InnoDB,\n PARTITION p202111SUB04 VALUES LESS THAN (738469) ENGINE = InnoDB,\n PARTITION p202111SUB05 VALUES LESS THAN (738471) ENGINE = InnoDB,\n PARTITION p202111SUB06 VALUES LESS THAN (738473) ENGINE = InnoDB,\n PARTITION p202111SUB07 VALUES LESS THAN (738475) ENGINE = InnoDB,\n PARTITION p202111SUB08 VALUES LESS THAN (738477) ENGINE = InnoDB,\n PARTITION p202111SUB09 VALUES LESS THAN (738479) ENGINE = InnoDB,\n PARTITION p202111SUB10 VALUES LESS THAN (738481) ENGINE = InnoDB,\n PARTITION p202111SUB11 VALUES LESS THAN (738483) ENGINE = InnoDB,\n PARTITION p202111SUB12 VALUES LESS THAN (738485) ENGINE = InnoDB,\n PARTITION p202111SUB13 VALUES LESS THAN (738487) ENGINE = InnoDB,\n PARTITION p202111SUB14 VALUES LESS THAN (738489) ENGINE = InnoDB,\n PARTITION p202112SUB00 VALUES LESS THAN (738491) ENGINE = InnoDB,\n PARTITION p202112SUB01 VALUES LESS THAN (738493) ENGINE = InnoDB,\n PARTITION p202112SUB02 VALUES LESS THAN (738495) ENGINE = InnoDB,\n PARTITION p202112SUB03 VALUES LESS THAN (738497) ENGINE = InnoDB,\n PARTITION p202112SUB04 VALUES LESS THAN (738499) ENGINE = InnoDB,\n PARTITION p202112SUB05 VALUES LESS THAN (738501) ENGINE = InnoDB,\n PARTITION p202112SUB06 VALUES LESS THAN (738503) ENGINE = InnoDB,\n PARTITION p202112SUB07 VALUES LESS THAN (738505) ENGINE = InnoDB,\n PARTITION p202112SUB08 VALUES LESS THAN (738507) ENGINE = InnoDB,\n PARTITION p202112SUB09 VALUES LESS THAN (738509) ENGINE = InnoDB,\n PARTITION p202112SUB10 VALUES LESS THAN (738511) ENGINE = InnoDB,\n PARTITION p202112SUB11 VALUES LESS THAN (738513) ENGINE = InnoDB,\n PARTITION p202112SUB12 VALUES LESS THAN (738515) ENGINE = InnoDB,\n PARTITION p202112SUB13 VALUES LESS THAN (738517) ENGINE = InnoDB,\n PARTITION p202112SUB14 VALUES LESS THAN (738519) ENGINE = InnoDB,\n PARTITION p202201SUB00 VALUES LESS THAN (738522) ENGINE = InnoDB,\n PARTITION p202201SUB01 VALUES LESS THAN (738524) ENGINE = InnoDB,\n PARTITION p202201SUB02 VALUES LESS THAN (738526) ENGINE = InnoDB,\n PARTITION p202201SUB03 VALUES LESS THAN (738528) ENGINE = InnoDB,\n PARTITION p202201SUB04 VALUES LESS THAN (738530) ENGINE = InnoDB,\n PARTITION p202201SUB05 VALUES LESS THAN (738532) ENGINE = InnoDB,\n PARTITION p202201SUB06 VALUES LESS THAN (738534) ENGINE = InnoDB,\n PARTITION p202201SUB07 VALUES LESS THAN (738536) ENGINE = InnoDB,\n PARTITION p202201SUB08 VALUES LESS THAN (738538) ENGINE = InnoDB,\n PARTITION p202201SUB09 VALUES LESS THAN (738540) ENGINE = InnoDB,\n PARTITION p202201SUB10 VALUES LESS THAN (738542) ENGINE = InnoDB,\n PARTITION p202201SUB11 VALUES LESS THAN (738544) ENGINE = InnoDB,\n PARTITION p202201SUB12 VALUES LESS THAN (738546) ENGINE = InnoDB,\n PARTITION p202201SUB13 VALUES LESS THAN (738548) ENGINE = InnoDB,\n PARTITION p202201SUB14 VALUES LESS THAN (738550) ENGINE = InnoDB,\n PARTITION p202202SUB00 VALUES LESS THAN (738553) ENGINE = InnoDB,\n PARTITION p202202SUB01 VALUES LESS THAN (738555) ENGINE = InnoDB,\n PARTITION p202202SUB02 VALUES LESS THAN (738557) ENGINE = InnoDB,\n PARTITION p202202SUB03 VALUES LESS THAN (738559) ENGINE = InnoDB,\n PARTITION p202202SUB04 VALUES LESS THAN (738561) ENGINE = InnoDB,\n PARTITION p202202SUB05 VALUES LESS THAN (738563) ENGINE = InnoDB,\n PARTITION p202202SUB06 VALUES LESS THAN (738565) ENGINE = InnoDB,\n PARTITION p202202SUB07 VALUES LESS THAN (738567) ENGINE = InnoDB,\n PARTITION p202202SUB08 VALUES LESS THAN (738569) ENGINE = InnoDB,\n PARTITION p202202SUB09 VALUES LESS THAN (738571) ENGINE = InnoDB,\n PARTITION p202202SUB10 VALUES LESS THAN (738573) ENGINE = InnoDB,\n PARTITION p202202SUB11 VALUES LESS THAN (738575) ENGINE = InnoDB,\n PARTITION p202202SUB12 VALUES LESS THAN (738577) ENGINE = InnoDB,\n PARTITION p202202SUB13 VALUES LESS THAN (738579) ENGINE = InnoDB,\n PARTITION p202203SUB00 VALUES LESS THAN (738581) ENGINE = InnoDB,\n PARTITION p202203SUB01 VALUES LESS THAN (738583) ENGINE = InnoDB,\n PARTITION p202203SUB02 VALUES LESS THAN (738585) ENGINE = InnoDB,\n PARTITION p202203SUB03 VALUES LESS THAN (738587) ENGINE = InnoDB,\n PARTITION p202203SUB04 VALUES LESS THAN (738589) ENGINE = InnoDB,\n PARTITION p202203SUB05 VALUES LESS THAN (738591) ENGINE = InnoDB,\n PARTITION p202203SUB06 VALUES LESS THAN (738593) ENGINE = InnoDB,\n PARTITION p202203SUB07 VALUES LESS THAN (738595) ENGINE = InnoDB,\n PARTITION p202203SUB08 VALUES LESS THAN (738597) ENGINE = InnoDB,\n PARTITION p202203SUB09 VALUES LESS THAN (738599) ENGINE = InnoDB,\n PARTITION p202203SUB10 VALUES LESS THAN (738601) ENGINE = InnoDB,\n PARTITION p202203SUB11 VALUES LESS THAN (738603) ENGINE = InnoDB,\n PARTITION p202203SUB12 VALUES LESS THAN (738605) ENGINE = InnoDB,\n PARTITION p202203SUB13 VALUES LESS THAN (738607) ENGINE = InnoDB,\n PARTITION p202203SUB14 VALUES LESS THAN (738609) ENGINE = InnoDB,\n PARTITION p202204SUB00 VALUES LESS THAN (738612) ENGINE = InnoDB,\n PARTITION p202204SUB01 VALUES LESS THAN (738614) ENGINE = InnoDB,\n PARTITION p202204SUB02 VALUES LESS THAN (738616) ENGINE = InnoDB,\n PARTITION p202204SUB03 VALUES LESS THAN (738618) ENGINE = InnoDB,\n PARTITION p202204SUB04 VALUES LESS THAN (738620) ENGINE = InnoDB,\n PARTITION p202204SUB05 VALUES LESS THAN (738622) ENGINE = InnoDB,\n PARTITION p202204SUB06 VALUES LESS THAN (738624) ENGINE = InnoDB,\n PARTITION p202204SUB07 VALUES LESS THAN (738626) ENGINE = InnoDB,\n PARTITION p202204SUB08 VALUES LESS THAN (738628) ENGINE = InnoDB,\n PARTITION p202204SUB09 VALUES LESS THAN (738630) ENGINE = InnoDB,\n PARTITION p202204SUB10 VALUES LESS THAN (738632) ENGINE = InnoDB,\n PARTITION p202204SUB11 VALUES LESS THAN (738634) ENGINE = InnoDB,\n PARTITION p202204SUB12 VALUES LESS THAN (738636) ENGINE = InnoDB,\n PARTITION p202204SUB13 VALUES LESS THAN (738638) ENGINE = InnoDB,\n PARTITION p202204SUB14 VALUES LESS THAN (738640) ENGINE = InnoDB,\n PARTITION p202205SUB00 VALUES LESS THAN (738642) ENGINE = InnoDB,\n PARTITION p202205SUB01 VALUES LESS THAN (738644) ENGINE = InnoDB,\n PARTITION p202205SUB02 VALUES LESS THAN (738646) ENGINE = InnoDB,\n PARTITION p202205SUB03 VALUES LESS THAN (738648) ENGINE = InnoDB,\n PARTITION p202205SUB04 VALUES LESS THAN (738650) ENGINE = InnoDB,\n PARTITION p202205SUB05 VALUES LESS THAN (738652) ENGINE = InnoDB,\n PARTITION p202205SUB06 VALUES LESS THAN (738654) ENGINE = InnoDB,\n PARTITION p202205SUB07 VALUES LESS THAN (738656) ENGINE = InnoDB,\n PARTITION p202205SUB08 VALUES LESS THAN (738658) ENGINE = InnoDB,\n PARTITION p202205SUB09 VALUES LESS THAN (738660) ENGINE = InnoDB,\n PARTITION p202205SUB10 VALUES LESS THAN (738662) ENGINE = InnoDB,\n PARTITION p202205SUB11 VALUES LESS THAN (738664) ENGINE = InnoDB,\n PARTITION p202205SUB12 VALUES LESS THAN (738666) ENGINE = InnoDB,\n PARTITION p202205SUB13 VALUES LESS THAN (738668) ENGINE = InnoDB,\n PARTITION p202205SUB14 VALUES LESS THAN (738670) ENGINE = InnoDB,\n PARTITION p202206SUB00 VALUES LESS THAN (738673) ENGINE = InnoDB,\n PARTITION p202206SUB01 VALUES LESS THAN (738675) ENGINE = InnoDB,\n PARTITION p202206SUB02 VALUES LESS THAN (738677) ENGINE = InnoDB,\n PARTITION p202206SUB03 VALUES LESS THAN (738679) ENGINE = InnoDB,\n PARTITION p202206SUB04 VALUES LESS THAN (738681) ENGINE = InnoDB,\n PARTITION p202206SUB05 VALUES LESS THAN (738683) ENGINE = InnoDB,\n PARTITION p202206SUB06 VALUES LESS THAN (738685) ENGINE = InnoDB,\n PARTITION p202206SUB07 VALUES LESS THAN (738687) ENGINE = InnoDB,\n PARTITION p202206SUB08 VALUES LESS THAN (738689) ENGINE = InnoDB,\n PARTITION p202206SUB09 VALUES LESS THAN (738691) ENGINE = InnoDB,\n PARTITION p202206SUB10 VALUES LESS THAN (738693) ENGINE = InnoDB,\n PARTITION p202206SUB11 VALUES LESS THAN (738695) ENGINE = InnoDB,\n PARTITION p202206SUB12 VALUES LESS THAN (738697) ENGINE = InnoDB,\n PARTITION p202206SUB13 VALUES LESS THAN (738699) ENGINE = InnoDB,\n PARTITION p202206SUB14 VALUES LESS THAN (738701) ENGINE = InnoDB,\n PARTITION p202207SUB00 VALUES LESS THAN (738703) ENGINE = InnoDB,\n PARTITION p202207SUB01 VALUES LESS THAN (738705) ENGINE = InnoDB,\n PARTITION p202207SUB02 VALUES LESS THAN (738707) ENGINE = InnoDB,\n PARTITION p202207SUB03 VALUES LESS THAN (738709) ENGINE = InnoDB,\n PARTITION p202207SUB04 VALUES LESS THAN (738711) ENGINE = InnoDB,\n PARTITION p202207SUB05 VALUES LESS THAN (738713) ENGINE = InnoDB,\n PARTITION p202207SUB06 VALUES LESS THAN (738715) ENGINE = InnoDB,\n PARTITION p202207SUB07 VALUES LESS THAN (738717) ENGINE = InnoDB,\n PARTITION p202207SUB08 VALUES LESS THAN (738719) ENGINE = InnoDB,\n PARTITION p202207SUB09 VALUES LESS THAN (738721) ENGINE = InnoDB,\n PARTITION p202207SUB10 VALUES LESS THAN (738723) ENGINE = InnoDB,\n PARTITION p202207SUB11 VALUES LESS THAN (738725) ENGINE = InnoDB,\n PARTITION p202207SUB12 VALUES LESS THAN (738727) ENGINE = InnoDB,\n PARTITION p202207SUB13 VALUES LESS THAN (738729) ENGINE = InnoDB,\n PARTITION p202207SUB14 VALUES LESS THAN (738731) ENGINE = InnoDB,\n PARTITION p202208SUB00 VALUES LESS THAN (738734) ENGINE = InnoDB,\n PARTITION p202208SUB01 VALUES LESS THAN (738736) ENGINE = InnoDB,\n PARTITION p202208SUB02 VALUES LESS THAN (738738) ENGINE = InnoDB,\n PARTITION p202208SUB03 VALUES LESS THAN (738740) ENGINE = InnoDB,\n PARTITION p202208SUB04 VALUES LESS THAN (738742) ENGINE = InnoDB,\n PARTITION p202208SUB05 VALUES LESS THAN (738744) ENGINE = InnoDB,\n PARTITION p202208SUB06 VALUES LESS THAN (738746) ENGINE = InnoDB,\n PARTITION p202208SUB07 VALUES LESS THAN (738748) ENGINE = InnoDB,\n PARTITION p202208SUB08 VALUES LESS THAN (738750) ENGINE = InnoDB,\n PARTITION p202208SUB09 VALUES LESS THAN (738752) ENGINE = InnoDB,\n PARTITION p202208SUB10 VALUES LESS THAN (738754) ENGINE = InnoDB,\n PARTITION p202208SUB11 VALUES LESS THAN (738756) ENGINE = InnoDB,\n PARTITION p202208SUB12 VALUES LESS THAN (738758) ENGINE = InnoDB,\n PARTITION p202208SUB13 VALUES LESS THAN (738760) ENGINE = InnoDB,\n PARTITION p202208SUB14 VALUES LESS THAN (738762) ENGINE = InnoDB,\n PARTITION p202209SUB00 VALUES LESS THAN (738765) ENGINE = InnoDB,\n PARTITION p202209SUB01 VALUES LESS THAN (738767) ENGINE = InnoDB,\n PARTITION p202209SUB02 VALUES LESS THAN (738769) ENGINE = InnoDB,\n PARTITION p202209SUB03 VALUES LESS THAN (738771) ENGINE = InnoDB,\n PARTITION p202209SUB04 VALUES LESS THAN (738773) ENGINE = InnoDB,\n PARTITION p202209SUB05 VALUES LESS THAN (738775) ENGINE = InnoDB,\n PARTITION p202209SUB06 VALUES LESS THAN (738777) ENGINE = InnoDB,\n PARTITION p202209SUB07 VALUES LESS THAN (738779) ENGINE = InnoDB,\n PARTITION p202209SUB08 VALUES LESS THAN (738781) ENGINE = InnoDB,\n PARTITION p202209SUB09 VALUES LESS THAN (738783) ENGINE = InnoDB,\n PARTITION p202209SUB10 VALUES LESS THAN (738785) ENGINE = InnoDB,\n PARTITION p202209SUB11 VALUES LESS THAN (738787) ENGINE = InnoDB,\n PARTITION p202209SUB12 VALUES LESS THAN (738789) ENGINE = InnoDB,\n PARTITION p202209SUB13 VALUES LESS THAN (738791) ENGINE = InnoDB,\n PARTITION p202209SUB14 VALUES LESS THAN (738793) ENGINE = InnoDB,\n PARTITION p202210SUB00 VALUES LESS THAN (738795) ENGINE = InnoDB,\n PARTITION p202210SUB01 VALUES LESS THAN (738797) ENGINE = InnoDB,\n PARTITION p202210SUB02 VALUES LESS THAN (738799) ENGINE = InnoDB,\n PARTITION p202210SUB03 VALUES LESS THAN (738801) ENGINE = InnoDB,\n PARTITION p202210SUB04 VALUES LESS THAN (738803) ENGINE = InnoDB,\n PARTITION p202210SUB05 VALUES LESS THAN (738805) ENGINE = InnoDB,\n PARTITION p202210SUB06 VALUES LESS THAN (738807) ENGINE = InnoDB,\n PARTITION p202210SUB07 VALUES LESS THAN (738809) ENGINE = InnoDB,\n PARTITION p202210SUB08 VALUES LESS THAN (738811) ENGINE = InnoDB,\n PARTITION p202210SUB09 VALUES LESS THAN (738813) ENGINE = InnoDB,\n PARTITION p202210SUB10 VALUES LESS THAN (738815) ENGINE = InnoDB,\n PARTITION p202210SUB11 VALUES LESS THAN (738817) ENGINE = InnoDB,\n PARTITION p202210SUB12 VALUES LESS THAN (738819) ENGINE = InnoDB,\n PARTITION p202210SUB13 VALUES LESS THAN (738821) ENGINE = InnoDB,\n PARTITION p202210SUB14 VALUES LESS THAN (738823) ENGINE = InnoDB,\n PARTITION p202211SUB00 VALUES LESS THAN (738826) ENGINE = InnoDB,\n PARTITION p202211SUB01 VALUES LESS THAN (738828) ENGINE = InnoDB,\n PARTITION p202211SUB02 VALUES LESS THAN (738830) ENGINE = InnoDB,\n PARTITION p202211SUB03 VALUES LESS THAN (738832) ENGINE = InnoDB,\n PARTITION p202211SUB04 VALUES LESS THAN (738834) ENGINE = InnoDB,\n PARTITION p202211SUB05 VALUES LESS THAN (738836) ENGINE = InnoDB,\n PARTITION p202211SUB06 VALUES LESS THAN (738838) ENGINE = InnoDB,\n PARTITION p202211SUB07 VALUES LESS THAN (738840) ENGINE = InnoDB,\n PARTITION p202211SUB08 VALUES LESS THAN (738842) ENGINE = InnoDB,\n PARTITION p202211SUB09 VALUES LESS THAN (738844) ENGINE = InnoDB,\n PARTITION p202211SUB10 VALUES LESS THAN (738846) ENGINE = InnoDB,\n PARTITION p202211SUB11 VALUES LESS THAN (738848) ENGINE = InnoDB,\n PARTITION p202211SUB12 VALUES LESS THAN (738850) ENGINE = InnoDB,\n PARTITION p202211SUB13 VALUES LESS THAN (738852) ENGINE = InnoDB,\n PARTITION p202211SUB14 VALUES LESS THAN (738854) ENGINE = InnoDB,\n PARTITION p202212SUB00 VALUES LESS THAN (738856) ENGINE = InnoDB,\n PARTITION p202212SUB01 VALUES LESS THAN (738858) ENGINE = InnoDB,\n PARTITION p202212SUB02 VALUES LESS THAN (738860) ENGINE = InnoDB,\n PARTITION p202212SUB03 VALUES LESS THAN (738862) ENGINE = InnoDB,\n PARTITION p202212SUB04 VALUES LESS THAN (738864) ENGINE = InnoDB,\n PARTITION p202212SUB05 VALUES LESS THAN (738866) ENGINE = InnoDB,\n PARTITION p202212SUB06 VALUES LESS THAN (738868) ENGINE = InnoDB,\n PARTITION p202212SUB07 VALUES LESS THAN (738870) ENGINE = InnoDB,\n PARTITION p202212SUB08 VALUES LESS THAN (738872) ENGINE = InnoDB,\n PARTITION p202212SUB09 VALUES LESS THAN (738874) ENGINE = InnoDB,\n PARTITION p202212SUB10 VALUES LESS THAN (738876) ENGINE = InnoDB,\n PARTITION p202212SUB11 VALUES LESS THAN (738878) ENGINE = InnoDB,\n PARTITION p202212SUB12 VALUES LESS THAN (738880) ENGINE = InnoDB,\n PARTITION p202212SUB13 VALUES LESS THAN (738882) ENGINE = InnoDB,\n PARTITION p202212SUB14 VALUES LESS THAN (738884) ENGINE = InnoDB) */", force: :cascade do |t|
    t.string "id", default: "", null: false, collation: "utf8_general_ci"
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "subid_1", collation: "utf8_general_ci"
    t.string "subid_2", collation: "utf8_general_ci"
    t.string "subid_3", collation: "utf8_general_ci"
    t.integer "language_id"
    t.string "http_user_agent", collation: "utf8_general_ci"
    t.string "http_referer", collation: "utf8_general_ci"
    t.string "ip_address", collation: "utf8_general_ci"
    t.integer "clicks"
    t.integer "conversions"
    t.datetime "recorded_at", default: "1970-01-01 00:00:00", null: false
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500, collation: "utf8_general_ci"
    t.string "status", collation: "utf8_general_ci"
    t.integer "image_creative_id"
    t.datetime "converted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "vtm_host", collation: "utf8_general_ci"
    t.string "vtm_page", collation: "utf8_general_ci"
    t.string "vtm_channel", collation: "utf8_general_ci"
    t.integer "mkt_site_id"
    t.integer "hits"
    t.integer "mkt_url_id"
    t.string "vtm_campaign", collation: "utf8_general_ci"
    t.string "ip_country", collation: "utf8_general_ci"
    t.string "approval", collation: "utf8_general_ci"
    t.integer "order_id"
    t.string "step_name", collation: "utf8_general_ci"
    t.string "step_label", collation: "utf8_general_ci"
    t.string "true_conv_type", collation: "utf8_general_ci"
    t.string "affiliate_conv_type", collation: "utf8_general_ci"
    t.integer "lead_id"
    t.string "s1", collation: "utf8_general_ci"
    t.string "s2", collation: "utf8_general_ci"
    t.string "s3", collation: "utf8_general_ci"
    t.string "s4", collation: "utf8_general_ci"
    t.boolean "is_bot"
    t.integer "text_creative_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.string "keyword", collation: "utf8_general_ci"
    t.integer "share_creative_id"
    t.datetime "captured_at", default: "1970-01-01 00:00:00", null: false
    t.string "isp", collation: "utf8_general_ci"
    t.string "browser", collation: "utf8_general_ci"
    t.string "browser_version", collation: "utf8_general_ci"
    t.string "device_type", collation: "utf8_general_ci"
    t.string "device_brand", collation: "utf8_general_ci"
    t.string "device_model", collation: "utf8_general_ci"
    t.string "aff_uniq_id", collation: "utf8_general_ci"
    t.string "ios_uniq", collation: "utf8_general_ci"
    t.string "android_uniq", collation: "utf8_general_ci"
    t.string "subid_4", collation: "utf8_general_ci"
    t.string "subid_5", collation: "utf8_general_ci"
    t.string "order_number", collation: "utf8_general_ci"
    t.string "gaid", collation: "utf8_general_ci"
    t.integer "email_creative_id"
    t.decimal "qscore", precision: 10, scale: 2
    t.string "ad_slot_id", collation: "utf8_general_ci"
    t.integer "impression"
    t.datetime "published_at"
    t.json "forex"
    t.string "original_currency", limit: 3
    t.string "adv_uniq_id"
    t.decimal "order_total", precision: 20, scale: 2
    t.index ["affiliate_id"], name: "index_affiliate_stat_captured_ats_on_affiliate_id"
    t.index ["id"], name: "index_affiliate_stat_captured_ats_on_id"
    t.index ["network_id"], name: "index_affiliate_stat_captured_ats_on_network_id"
    t.index ["offer_id"], name: "index_affiliate_stat_captured_ats_on_offer_id"
    t.index ["order_number"], name: "index_affiliate_stat_captured_ats_on_order_number"
    t.index ["updated_at"], name: "index_affiliate_stat_captured_ats_on_updated_at"
  end

  create_table "affiliate_stat_converted_ats", primary_key: ["converted_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", options: "ENGINE=InnoDB\n/*!50100 PARTITION BY RANGE ( TO_DAYS(converted_at))\n(PARTITION p201601SUB00 VALUES LESS THAN (736330) ENGINE = InnoDB,\n PARTITION p201601SUB01 VALUES LESS THAN (736332) ENGINE = InnoDB,\n PARTITION p201601SUB02 VALUES LESS THAN (736334) ENGINE = InnoDB,\n PARTITION p201601SUB03 VALUES LESS THAN (736336) ENGINE = InnoDB,\n PARTITION p201601SUB04 VALUES LESS THAN (736338) ENGINE = InnoDB,\n PARTITION p201601SUB05 VALUES LESS THAN (736340) ENGINE = InnoDB,\n PARTITION p201601SUB06 VALUES LESS THAN (736342) ENGINE = InnoDB,\n PARTITION p201601SUB07 VALUES LESS THAN (736344) ENGINE = InnoDB,\n PARTITION p201601SUB08 VALUES LESS THAN (736346) ENGINE = InnoDB,\n PARTITION p201601SUB09 VALUES LESS THAN (736348) ENGINE = InnoDB,\n PARTITION p201601SUB10 VALUES LESS THAN (736350) ENGINE = InnoDB,\n PARTITION p201601SUB11 VALUES LESS THAN (736352) ENGINE = InnoDB,\n PARTITION p201601SUB12 VALUES LESS THAN (736354) ENGINE = InnoDB,\n PARTITION p201601SUB13 VALUES LESS THAN (736356) ENGINE = InnoDB,\n PARTITION p201601SUB14 VALUES LESS THAN (736358) ENGINE = InnoDB,\n PARTITION p201602SUB00 VALUES LESS THAN (736361) ENGINE = InnoDB,\n PARTITION p201602SUB01 VALUES LESS THAN (736363) ENGINE = InnoDB,\n PARTITION p201602SUB02 VALUES LESS THAN (736365) ENGINE = InnoDB,\n PARTITION p201602SUB03 VALUES LESS THAN (736367) ENGINE = InnoDB,\n PARTITION p201602SUB04 VALUES LESS THAN (736369) ENGINE = InnoDB,\n PARTITION p201602SUB05 VALUES LESS THAN (736371) ENGINE = InnoDB,\n PARTITION p201602SUB06 VALUES LESS THAN (736373) ENGINE = InnoDB,\n PARTITION p201602SUB07 VALUES LESS THAN (736375) ENGINE = InnoDB,\n PARTITION p201602SUB08 VALUES LESS THAN (736377) ENGINE = InnoDB,\n PARTITION p201602SUB09 VALUES LESS THAN (736379) ENGINE = InnoDB,\n PARTITION p201602SUB10 VALUES LESS THAN (736381) ENGINE = InnoDB,\n PARTITION p201602SUB11 VALUES LESS THAN (736383) ENGINE = InnoDB,\n PARTITION p201602SUB12 VALUES LESS THAN (736385) ENGINE = InnoDB,\n PARTITION p201602SUB13 VALUES LESS THAN (736387) ENGINE = InnoDB,\n PARTITION p201603SUB00 VALUES LESS THAN (736390) ENGINE = InnoDB,\n PARTITION p201603SUB01 VALUES LESS THAN (736392) ENGINE = InnoDB,\n PARTITION p201603SUB02 VALUES LESS THAN (736394) ENGINE = InnoDB,\n PARTITION p201603SUB03 VALUES LESS THAN (736396) ENGINE = InnoDB,\n PARTITION p201603SUB04 VALUES LESS THAN (736398) ENGINE = InnoDB,\n PARTITION p201603SUB05 VALUES LESS THAN (736400) ENGINE = InnoDB,\n PARTITION p201603SUB06 VALUES LESS THAN (736402) ENGINE = InnoDB,\n PARTITION p201603SUB07 VALUES LESS THAN (736404) ENGINE = InnoDB,\n PARTITION p201603SUB08 VALUES LESS THAN (736406) ENGINE = InnoDB,\n PARTITION p201603SUB09 VALUES LESS THAN (736408) ENGINE = InnoDB,\n PARTITION p201603SUB10 VALUES LESS THAN (736410) ENGINE = InnoDB,\n PARTITION p201603SUB11 VALUES LESS THAN (736412) ENGINE = InnoDB,\n PARTITION p201603SUB12 VALUES LESS THAN (736414) ENGINE = InnoDB,\n PARTITION p201603SUB13 VALUES LESS THAN (736416) ENGINE = InnoDB,\n PARTITION p201603SUB14 VALUES LESS THAN (736418) ENGINE = InnoDB,\n PARTITION p201604SUB00 VALUES LESS THAN (736421) ENGINE = InnoDB,\n PARTITION p201604SUB01 VALUES LESS THAN (736423) ENGINE = InnoDB,\n PARTITION p201604SUB02 VALUES LESS THAN (736425) ENGINE = InnoDB,\n PARTITION p201604SUB03 VALUES LESS THAN (736427) ENGINE = InnoDB,\n PARTITION p201604SUB04 VALUES LESS THAN (736429) ENGINE = InnoDB,\n PARTITION p201604SUB05 VALUES LESS THAN (736431) ENGINE = InnoDB,\n PARTITION p201604SUB06 VALUES LESS THAN (736433) ENGINE = InnoDB,\n PARTITION p201604SUB07 VALUES LESS THAN (736435) ENGINE = InnoDB,\n PARTITION p201604SUB08 VALUES LESS THAN (736437) ENGINE = InnoDB,\n PARTITION p201604SUB09 VALUES LESS THAN (736439) ENGINE = InnoDB,\n PARTITION p201604SUB10 VALUES LESS THAN (736441) ENGINE = InnoDB,\n PARTITION p201604SUB11 VALUES LESS THAN (736443) ENGINE = InnoDB,\n PARTITION p201604SUB12 VALUES LESS THAN (736445) ENGINE = InnoDB,\n PARTITION p201604SUB13 VALUES LESS THAN (736447) ENGINE = InnoDB,\n PARTITION p201604SUB14 VALUES LESS THAN (736449) ENGINE = InnoDB,\n PARTITION p201605SUB00 VALUES LESS THAN (736451) ENGINE = InnoDB,\n PARTITION p201605SUB01 VALUES LESS THAN (736453) ENGINE = InnoDB,\n PARTITION p201605SUB02 VALUES LESS THAN (736455) ENGINE = InnoDB,\n PARTITION p201605SUB03 VALUES LESS THAN (736457) ENGINE = InnoDB,\n PARTITION p201605SUB04 VALUES LESS THAN (736459) ENGINE = InnoDB,\n PARTITION p201605SUB05 VALUES LESS THAN (736461) ENGINE = InnoDB,\n PARTITION p201605SUB06 VALUES LESS THAN (736463) ENGINE = InnoDB,\n PARTITION p201605SUB07 VALUES LESS THAN (736465) ENGINE = InnoDB,\n PARTITION p201605SUB08 VALUES LESS THAN (736467) ENGINE = InnoDB,\n PARTITION p201605SUB09 VALUES LESS THAN (736469) ENGINE = InnoDB,\n PARTITION p201605SUB10 VALUES LESS THAN (736471) ENGINE = InnoDB,\n PARTITION p201605SUB11 VALUES LESS THAN (736473) ENGINE = InnoDB,\n PARTITION p201605SUB12 VALUES LESS THAN (736475) ENGINE = InnoDB,\n PARTITION p201605SUB13 VALUES LESS THAN (736477) ENGINE = InnoDB,\n PARTITION p201605SUB14 VALUES LESS THAN (736479) ENGINE = InnoDB,\n PARTITION p201606SUB00 VALUES LESS THAN (736482) ENGINE = InnoDB,\n PARTITION p201606SUB01 VALUES LESS THAN (736484) ENGINE = InnoDB,\n PARTITION p201606SUB02 VALUES LESS THAN (736486) ENGINE = InnoDB,\n PARTITION p201606SUB03 VALUES LESS THAN (736488) ENGINE = InnoDB,\n PARTITION p201606SUB04 VALUES LESS THAN (736490) ENGINE = InnoDB,\n PARTITION p201606SUB05 VALUES LESS THAN (736492) ENGINE = InnoDB,\n PARTITION p201606SUB06 VALUES LESS THAN (736494) ENGINE = InnoDB,\n PARTITION p201606SUB07 VALUES LESS THAN (736496) ENGINE = InnoDB,\n PARTITION p201606SUB08 VALUES LESS THAN (736498) ENGINE = InnoDB,\n PARTITION p201606SUB09 VALUES LESS THAN (736500) ENGINE = InnoDB,\n PARTITION p201606SUB10 VALUES LESS THAN (736502) ENGINE = InnoDB,\n PARTITION p201606SUB11 VALUES LESS THAN (736504) ENGINE = InnoDB,\n PARTITION p201606SUB12 VALUES LESS THAN (736506) ENGINE = InnoDB,\n PARTITION p201606SUB13 VALUES LESS THAN (736508) ENGINE = InnoDB,\n PARTITION p201606SUB14 VALUES LESS THAN (736510) ENGINE = InnoDB,\n PARTITION p201607SUB00 VALUES LESS THAN (736512) ENGINE = InnoDB,\n PARTITION p201607SUB01 VALUES LESS THAN (736514) ENGINE = InnoDB,\n PARTITION p201607SUB02 VALUES LESS THAN (736516) ENGINE = InnoDB,\n PARTITION p201607SUB03 VALUES LESS THAN (736518) ENGINE = InnoDB,\n PARTITION p201607SUB04 VALUES LESS THAN (736520) ENGINE = InnoDB,\n PARTITION p201607SUB05 VALUES LESS THAN (736522) ENGINE = InnoDB,\n PARTITION p201607SUB06 VALUES LESS THAN (736524) ENGINE = InnoDB,\n PARTITION p201607SUB07 VALUES LESS THAN (736526) ENGINE = InnoDB,\n PARTITION p201607SUB08 VALUES LESS THAN (736528) ENGINE = InnoDB,\n PARTITION p201607SUB09 VALUES LESS THAN (736530) ENGINE = InnoDB,\n PARTITION p201607SUB10 VALUES LESS THAN (736532) ENGINE = InnoDB,\n PARTITION p201607SUB11 VALUES LESS THAN (736534) ENGINE = InnoDB,\n PARTITION p201607SUB12 VALUES LESS THAN (736536) ENGINE = InnoDB,\n PARTITION p201607SUB13 VALUES LESS THAN (736538) ENGINE = InnoDB,\n PARTITION p201607SUB14 VALUES LESS THAN (736540) ENGINE = InnoDB,\n PARTITION p201608SUB00 VALUES LESS THAN (736543) ENGINE = InnoDB,\n PARTITION p201608SUB01 VALUES LESS THAN (736545) ENGINE = InnoDB,\n PARTITION p201608SUB02 VALUES LESS THAN (736547) ENGINE = InnoDB,\n PARTITION p201608SUB03 VALUES LESS THAN (736549) ENGINE = InnoDB,\n PARTITION p201608SUB04 VALUES LESS THAN (736551) ENGINE = InnoDB,\n PARTITION p201608SUB05 VALUES LESS THAN (736553) ENGINE = InnoDB,\n PARTITION p201608SUB06 VALUES LESS THAN (736555) ENGINE = InnoDB,\n PARTITION p201608SUB07 VALUES LESS THAN (736557) ENGINE = InnoDB,\n PARTITION p201608SUB08 VALUES LESS THAN (736559) ENGINE = InnoDB,\n PARTITION p201608SUB09 VALUES LESS THAN (736561) ENGINE = InnoDB,\n PARTITION p201608SUB10 VALUES LESS THAN (736563) ENGINE = InnoDB,\n PARTITION p201608SUB11 VALUES LESS THAN (736565) ENGINE = InnoDB,\n PARTITION p201608SUB12 VALUES LESS THAN (736567) ENGINE = InnoDB,\n PARTITION p201608SUB13 VALUES LESS THAN (736569) ENGINE = InnoDB,\n PARTITION p201608SUB14 VALUES LESS THAN (736571) ENGINE = InnoDB,\n PARTITION p201609SUB00 VALUES LESS THAN (736574) ENGINE = InnoDB,\n PARTITION p201609SUB01 VALUES LESS THAN (736576) ENGINE = InnoDB,\n PARTITION p201609SUB02 VALUES LESS THAN (736578) ENGINE = InnoDB,\n PARTITION p201609SUB03 VALUES LESS THAN (736580) ENGINE = InnoDB,\n PARTITION p201609SUB04 VALUES LESS THAN (736582) ENGINE = InnoDB,\n PARTITION p201609SUB05 VALUES LESS THAN (736584) ENGINE = InnoDB,\n PARTITION p201609SUB06 VALUES LESS THAN (736586) ENGINE = InnoDB,\n PARTITION p201609SUB07 VALUES LESS THAN (736588) ENGINE = InnoDB,\n PARTITION p201609SUB08 VALUES LESS THAN (736590) ENGINE = InnoDB,\n PARTITION p201609SUB09 VALUES LESS THAN (736592) ENGINE = InnoDB,\n PARTITION p201609SUB10 VALUES LESS THAN (736594) ENGINE = InnoDB,\n PARTITION p201609SUB11 VALUES LESS THAN (736596) ENGINE = InnoDB,\n PARTITION p201609SUB12 VALUES LESS THAN (736598) ENGINE = InnoDB,\n PARTITION p201609SUB13 VALUES LESS THAN (736600) ENGINE = InnoDB,\n PARTITION p201609SUB14 VALUES LESS THAN (736602) ENGINE = InnoDB,\n PARTITION p201610SUB00 VALUES LESS THAN (736604) ENGINE = InnoDB,\n PARTITION p201610SUB01 VALUES LESS THAN (736606) ENGINE = InnoDB,\n PARTITION p201610SUB02 VALUES LESS THAN (736608) ENGINE = InnoDB,\n PARTITION p201610SUB03 VALUES LESS THAN (736610) ENGINE = InnoDB,\n PARTITION p201610SUB04 VALUES LESS THAN (736612) ENGINE = InnoDB,\n PARTITION p201610SUB05 VALUES LESS THAN (736614) ENGINE = InnoDB,\n PARTITION p201610SUB06 VALUES LESS THAN (736616) ENGINE = InnoDB,\n PARTITION p201610SUB07 VALUES LESS THAN (736618) ENGINE = InnoDB,\n PARTITION p201610SUB08 VALUES LESS THAN (736620) ENGINE = InnoDB,\n PARTITION p201610SUB09 VALUES LESS THAN (736622) ENGINE = InnoDB,\n PARTITION p201610SUB10 VALUES LESS THAN (736624) ENGINE = InnoDB,\n PARTITION p201610SUB11 VALUES LESS THAN (736626) ENGINE = InnoDB,\n PARTITION p201610SUB12 VALUES LESS THAN (736628) ENGINE = InnoDB,\n PARTITION p201610SUB13 VALUES LESS THAN (736630) ENGINE = InnoDB,\n PARTITION p201610SUB14 VALUES LESS THAN (736632) ENGINE = InnoDB,\n PARTITION p201611SUB00 VALUES LESS THAN (736635) ENGINE = InnoDB,\n PARTITION p201611SUB01 VALUES LESS THAN (736637) ENGINE = InnoDB,\n PARTITION p201611SUB02 VALUES LESS THAN (736639) ENGINE = InnoDB,\n PARTITION p201611SUB03 VALUES LESS THAN (736641) ENGINE = InnoDB,\n PARTITION p201611SUB04 VALUES LESS THAN (736643) ENGINE = InnoDB,\n PARTITION p201611SUB05 VALUES LESS THAN (736645) ENGINE = InnoDB,\n PARTITION p201611SUB06 VALUES LESS THAN (736647) ENGINE = InnoDB,\n PARTITION p201611SUB07 VALUES LESS THAN (736649) ENGINE = InnoDB,\n PARTITION p201611SUB08 VALUES LESS THAN (736651) ENGINE = InnoDB,\n PARTITION p201611SUB09 VALUES LESS THAN (736653) ENGINE = InnoDB,\n PARTITION p201611SUB10 VALUES LESS THAN (736655) ENGINE = InnoDB,\n PARTITION p201611SUB11 VALUES LESS THAN (736657) ENGINE = InnoDB,\n PARTITION p201611SUB12 VALUES LESS THAN (736659) ENGINE = InnoDB,\n PARTITION p201611SUB13 VALUES LESS THAN (736661) ENGINE = InnoDB,\n PARTITION p201611SUB14 VALUES LESS THAN (736663) ENGINE = InnoDB,\n PARTITION p201612SUB00 VALUES LESS THAN (736665) ENGINE = InnoDB,\n PARTITION p201612SUB01 VALUES LESS THAN (736667) ENGINE = InnoDB,\n PARTITION p201612SUB02 VALUES LESS THAN (736669) ENGINE = InnoDB,\n PARTITION p201612SUB03 VALUES LESS THAN (736671) ENGINE = InnoDB,\n PARTITION p201612SUB04 VALUES LESS THAN (736673) ENGINE = InnoDB,\n PARTITION p201612SUB05 VALUES LESS THAN (736675) ENGINE = InnoDB,\n PARTITION p201612SUB06 VALUES LESS THAN (736677) ENGINE = InnoDB,\n PARTITION p201612SUB07 VALUES LESS THAN (736679) ENGINE = InnoDB,\n PARTITION p201612SUB08 VALUES LESS THAN (736681) ENGINE = InnoDB,\n PARTITION p201612SUB09 VALUES LESS THAN (736683) ENGINE = InnoDB,\n PARTITION p201612SUB10 VALUES LESS THAN (736685) ENGINE = InnoDB,\n PARTITION p201612SUB11 VALUES LESS THAN (736687) ENGINE = InnoDB,\n PARTITION p201612SUB12 VALUES LESS THAN (736689) ENGINE = InnoDB,\n PARTITION p201612SUB13 VALUES LESS THAN (736691) ENGINE = InnoDB,\n PARTITION p201612SUB14 VALUES LESS THAN (736693) ENGINE = InnoDB,\n PARTITION p201701SUB00 VALUES LESS THAN (736696) ENGINE = InnoDB,\n PARTITION p201701SUB01 VALUES LESS THAN (736698) ENGINE = InnoDB,\n PARTITION p201701SUB02 VALUES LESS THAN (736700) ENGINE = InnoDB,\n PARTITION p201701SUB03 VALUES LESS THAN (736702) ENGINE = InnoDB,\n PARTITION p201701SUB04 VALUES LESS THAN (736704) ENGINE = InnoDB,\n PARTITION p201701SUB05 VALUES LESS THAN (736706) ENGINE = InnoDB,\n PARTITION p201701SUB06 VALUES LESS THAN (736708) ENGINE = InnoDB,\n PARTITION p201701SUB07 VALUES LESS THAN (736710) ENGINE = InnoDB,\n PARTITION p201701SUB08 VALUES LESS THAN (736712) ENGINE = InnoDB,\n PARTITION p201701SUB09 VALUES LESS THAN (736714) ENGINE = InnoDB,\n PARTITION p201701SUB10 VALUES LESS THAN (736716) ENGINE = InnoDB,\n PARTITION p201701SUB11 VALUES LESS THAN (736718) ENGINE = InnoDB,\n PARTITION p201701SUB12 VALUES LESS THAN (736720) ENGINE = InnoDB,\n PARTITION p201701SUB13 VALUES LESS THAN (736722) ENGINE = InnoDB,\n PARTITION p201701SUB14 VALUES LESS THAN (736724) ENGINE = InnoDB,\n PARTITION p201702SUB00 VALUES LESS THAN (736727) ENGINE = InnoDB,\n PARTITION p201702SUB01 VALUES LESS THAN (736729) ENGINE = InnoDB,\n PARTITION p201702SUB02 VALUES LESS THAN (736731) ENGINE = InnoDB,\n PARTITION p201702SUB03 VALUES LESS THAN (736733) ENGINE = InnoDB,\n PARTITION p201702SUB04 VALUES LESS THAN (736735) ENGINE = InnoDB,\n PARTITION p201702SUB05 VALUES LESS THAN (736737) ENGINE = InnoDB,\n PARTITION p201702SUB06 VALUES LESS THAN (736739) ENGINE = InnoDB,\n PARTITION p201702SUB07 VALUES LESS THAN (736741) ENGINE = InnoDB,\n PARTITION p201702SUB08 VALUES LESS THAN (736743) ENGINE = InnoDB,\n PARTITION p201702SUB09 VALUES LESS THAN (736745) ENGINE = InnoDB,\n PARTITION p201702SUB10 VALUES LESS THAN (736747) ENGINE = InnoDB,\n PARTITION p201702SUB11 VALUES LESS THAN (736749) ENGINE = InnoDB,\n PARTITION p201702SUB12 VALUES LESS THAN (736751) ENGINE = InnoDB,\n PARTITION p201702SUB13 VALUES LESS THAN (736753) ENGINE = InnoDB,\n PARTITION p201703SUB00 VALUES LESS THAN (736755) ENGINE = InnoDB,\n PARTITION p201703SUB01 VALUES LESS THAN (736757) ENGINE = InnoDB,\n PARTITION p201703SUB02 VALUES LESS THAN (736759) ENGINE = InnoDB,\n PARTITION p201703SUB03 VALUES LESS THAN (736761) ENGINE = InnoDB,\n PARTITION p201703SUB04 VALUES LESS THAN (736763) ENGINE = InnoDB,\n PARTITION p201703SUB05 VALUES LESS THAN (736765) ENGINE = InnoDB,\n PARTITION p201703SUB06 VALUES LESS THAN (736767) ENGINE = InnoDB,\n PARTITION p201703SUB07 VALUES LESS THAN (736769) ENGINE = InnoDB,\n PARTITION p201703SUB08 VALUES LESS THAN (736771) ENGINE = InnoDB,\n PARTITION p201703SUB09 VALUES LESS THAN (736773) ENGINE = InnoDB,\n PARTITION p201703SUB10 VALUES LESS THAN (736775) ENGINE = InnoDB,\n PARTITION p201703SUB11 VALUES LESS THAN (736777) ENGINE = InnoDB,\n PARTITION p201703SUB12 VALUES LESS THAN (736779) ENGINE = InnoDB,\n PARTITION p201703SUB13 VALUES LESS THAN (736781) ENGINE = InnoDB,\n PARTITION p201703SUB14 VALUES LESS THAN (736783) ENGINE = InnoDB,\n PARTITION p201704SUB00 VALUES LESS THAN (736786) ENGINE = InnoDB,\n PARTITION p201704SUB01 VALUES LESS THAN (736788) ENGINE = InnoDB,\n PARTITION p201704SUB02 VALUES LESS THAN (736790) ENGINE = InnoDB,\n PARTITION p201704SUB03 VALUES LESS THAN (736792) ENGINE = InnoDB,\n PARTITION p201704SUB04 VALUES LESS THAN (736794) ENGINE = InnoDB,\n PARTITION p201704SUB05 VALUES LESS THAN (736796) ENGINE = InnoDB,\n PARTITION p201704SUB06 VALUES LESS THAN (736798) ENGINE = InnoDB,\n PARTITION p201704SUB07 VALUES LESS THAN (736800) ENGINE = InnoDB,\n PARTITION p201704SUB08 VALUES LESS THAN (736802) ENGINE = InnoDB,\n PARTITION p201704SUB09 VALUES LESS THAN (736804) ENGINE = InnoDB,\n PARTITION p201704SUB10 VALUES LESS THAN (736806) ENGINE = InnoDB,\n PARTITION p201704SUB11 VALUES LESS THAN (736808) ENGINE = InnoDB,\n PARTITION p201704SUB12 VALUES LESS THAN (736810) ENGINE = InnoDB,\n PARTITION p201704SUB13 VALUES LESS THAN (736812) ENGINE = InnoDB,\n PARTITION p201704SUB14 VALUES LESS THAN (736814) ENGINE = InnoDB,\n PARTITION p201705SUB00 VALUES LESS THAN (736816) ENGINE = InnoDB,\n PARTITION p201705SUB01 VALUES LESS THAN (736818) ENGINE = InnoDB,\n PARTITION p201705SUB02 VALUES LESS THAN (736820) ENGINE = InnoDB,\n PARTITION p201705SUB03 VALUES LESS THAN (736822) ENGINE = InnoDB,\n PARTITION p201705SUB04 VALUES LESS THAN (736824) ENGINE = InnoDB,\n PARTITION p201705SUB05 VALUES LESS THAN (736826) ENGINE = InnoDB,\n PARTITION p201705SUB06 VALUES LESS THAN (736828) ENGINE = InnoDB,\n PARTITION p201705SUB07 VALUES LESS THAN (736830) ENGINE = InnoDB,\n PARTITION p201705SUB08 VALUES LESS THAN (736832) ENGINE = InnoDB,\n PARTITION p201705SUB09 VALUES LESS THAN (736834) ENGINE = InnoDB,\n PARTITION p201705SUB10 VALUES LESS THAN (736836) ENGINE = InnoDB,\n PARTITION p201705SUB11 VALUES LESS THAN (736838) ENGINE = InnoDB,\n PARTITION p201705SUB12 VALUES LESS THAN (736840) ENGINE = InnoDB,\n PARTITION p201705SUB13 VALUES LESS THAN (736842) ENGINE = InnoDB,\n PARTITION p201705SUB14 VALUES LESS THAN (736844) ENGINE = InnoDB,\n PARTITION p201706SUB00 VALUES LESS THAN (736847) ENGINE = InnoDB,\n PARTITION p201706SUB01 VALUES LESS THAN (736849) ENGINE = InnoDB,\n PARTITION p201706SUB02 VALUES LESS THAN (736851) ENGINE = InnoDB,\n PARTITION p201706SUB03 VALUES LESS THAN (736853) ENGINE = InnoDB,\n PARTITION p201706SUB04 VALUES LESS THAN (736855) ENGINE = InnoDB,\n PARTITION p201706SUB05 VALUES LESS THAN (736857) ENGINE = InnoDB,\n PARTITION p201706SUB06 VALUES LESS THAN (736859) ENGINE = InnoDB,\n PARTITION p201706SUB07 VALUES LESS THAN (736861) ENGINE = InnoDB,\n PARTITION p201706SUB08 VALUES LESS THAN (736863) ENGINE = InnoDB,\n PARTITION p201706SUB09 VALUES LESS THAN (736865) ENGINE = InnoDB,\n PARTITION p201706SUB10 VALUES LESS THAN (736867) ENGINE = InnoDB,\n PARTITION p201706SUB11 VALUES LESS THAN (736869) ENGINE = InnoDB,\n PARTITION p201706SUB12 VALUES LESS THAN (736871) ENGINE = InnoDB,\n PARTITION p201706SUB13 VALUES LESS THAN (736873) ENGINE = InnoDB,\n PARTITION p201706SUB14 VALUES LESS THAN (736875) ENGINE = InnoDB,\n PARTITION p201707SUB00 VALUES LESS THAN (736877) ENGINE = InnoDB,\n PARTITION p201707SUB01 VALUES LESS THAN (736879) ENGINE = InnoDB,\n PARTITION p201707SUB02 VALUES LESS THAN (736881) ENGINE = InnoDB,\n PARTITION p201707SUB03 VALUES LESS THAN (736883) ENGINE = InnoDB,\n PARTITION p201707SUB04 VALUES LESS THAN (736885) ENGINE = InnoDB,\n PARTITION p201707SUB05 VALUES LESS THAN (736887) ENGINE = InnoDB,\n PARTITION p201707SUB06 VALUES LESS THAN (736889) ENGINE = InnoDB,\n PARTITION p201707SUB07 VALUES LESS THAN (736891) ENGINE = InnoDB,\n PARTITION p201707SUB08 VALUES LESS THAN (736893) ENGINE = InnoDB,\n PARTITION p201707SUB09 VALUES LESS THAN (736895) ENGINE = InnoDB,\n PARTITION p201707SUB10 VALUES LESS THAN (736897) ENGINE = InnoDB,\n PARTITION p201707SUB11 VALUES LESS THAN (736899) ENGINE = InnoDB,\n PARTITION p201707SUB12 VALUES LESS THAN (736901) ENGINE = InnoDB,\n PARTITION p201707SUB13 VALUES LESS THAN (736903) ENGINE = InnoDB,\n PARTITION p201707SUB14 VALUES LESS THAN (736905) ENGINE = InnoDB,\n PARTITION p201708SUB00 VALUES LESS THAN (736908) ENGINE = InnoDB,\n PARTITION p201708SUB01 VALUES LESS THAN (736910) ENGINE = InnoDB,\n PARTITION p201708SUB02 VALUES LESS THAN (736912) ENGINE = InnoDB,\n PARTITION p201708SUB03 VALUES LESS THAN (736914) ENGINE = InnoDB,\n PARTITION p201708SUB04 VALUES LESS THAN (736916) ENGINE = InnoDB,\n PARTITION p201708SUB05 VALUES LESS THAN (736918) ENGINE = InnoDB,\n PARTITION p201708SUB06 VALUES LESS THAN (736920) ENGINE = InnoDB,\n PARTITION p201708SUB07 VALUES LESS THAN (736922) ENGINE = InnoDB,\n PARTITION p201708SUB08 VALUES LESS THAN (736924) ENGINE = InnoDB,\n PARTITION p201708SUB09 VALUES LESS THAN (736926) ENGINE = InnoDB,\n PARTITION p201708SUB10 VALUES LESS THAN (736928) ENGINE = InnoDB,\n PARTITION p201708SUB11 VALUES LESS THAN (736930) ENGINE = InnoDB,\n PARTITION p201708SUB12 VALUES LESS THAN (736932) ENGINE = InnoDB,\n PARTITION p201708SUB13 VALUES LESS THAN (736934) ENGINE = InnoDB,\n PARTITION p201708SUB14 VALUES LESS THAN (736936) ENGINE = InnoDB,\n PARTITION p201709SUB00 VALUES LESS THAN (736939) ENGINE = InnoDB,\n PARTITION p201709SUB01 VALUES LESS THAN (736941) ENGINE = InnoDB,\n PARTITION p201709SUB02 VALUES LESS THAN (736943) ENGINE = InnoDB,\n PARTITION p201709SUB03 VALUES LESS THAN (736945) ENGINE = InnoDB,\n PARTITION p201709SUB04 VALUES LESS THAN (736947) ENGINE = InnoDB,\n PARTITION p201709SUB05 VALUES LESS THAN (736949) ENGINE = InnoDB,\n PARTITION p201709SUB06 VALUES LESS THAN (736951) ENGINE = InnoDB,\n PARTITION p201709SUB07 VALUES LESS THAN (736953) ENGINE = InnoDB,\n PARTITION p201709SUB08 VALUES LESS THAN (736955) ENGINE = InnoDB,\n PARTITION p201709SUB09 VALUES LESS THAN (736957) ENGINE = InnoDB,\n PARTITION p201709SUB10 VALUES LESS THAN (736959) ENGINE = InnoDB,\n PARTITION p201709SUB11 VALUES LESS THAN (736961) ENGINE = InnoDB,\n PARTITION p201709SUB12 VALUES LESS THAN (736963) ENGINE = InnoDB,\n PARTITION p201709SUB13 VALUES LESS THAN (736965) ENGINE = InnoDB,\n PARTITION p201709SUB14 VALUES LESS THAN (736967) ENGINE = InnoDB,\n PARTITION p201710SUB00 VALUES LESS THAN (736969) ENGINE = InnoDB,\n PARTITION p201710SUB01 VALUES LESS THAN (736971) ENGINE = InnoDB,\n PARTITION p201710SUB02 VALUES LESS THAN (736973) ENGINE = InnoDB,\n PARTITION p201710SUB03 VALUES LESS THAN (736975) ENGINE = InnoDB,\n PARTITION p201710SUB04 VALUES LESS THAN (736977) ENGINE = InnoDB,\n PARTITION p201710SUB05 VALUES LESS THAN (736979) ENGINE = InnoDB,\n PARTITION p201710SUB06 VALUES LESS THAN (736981) ENGINE = InnoDB,\n PARTITION p201710SUB07 VALUES LESS THAN (736983) ENGINE = InnoDB,\n PARTITION p201710SUB08 VALUES LESS THAN (736985) ENGINE = InnoDB,\n PARTITION p201710SUB09 VALUES LESS THAN (736987) ENGINE = InnoDB,\n PARTITION p201710SUB10 VALUES LESS THAN (736989) ENGINE = InnoDB,\n PARTITION p201710SUB11 VALUES LESS THAN (736991) ENGINE = InnoDB,\n PARTITION p201710SUB12 VALUES LESS THAN (736993) ENGINE = InnoDB,\n PARTITION p201710SUB13 VALUES LESS THAN (736995) ENGINE = InnoDB,\n PARTITION p201710SUB14 VALUES LESS THAN (736997) ENGINE = InnoDB,\n PARTITION p201711SUB00 VALUES LESS THAN (737000) ENGINE = InnoDB,\n PARTITION p201711SUB01 VALUES LESS THAN (737002) ENGINE = InnoDB,\n PARTITION p201711SUB02 VALUES LESS THAN (737004) ENGINE = InnoDB,\n PARTITION p201711SUB03 VALUES LESS THAN (737006) ENGINE = InnoDB,\n PARTITION p201711SUB04 VALUES LESS THAN (737008) ENGINE = InnoDB,\n PARTITION p201711SUB05 VALUES LESS THAN (737010) ENGINE = InnoDB,\n PARTITION p201711SUB06 VALUES LESS THAN (737012) ENGINE = InnoDB,\n PARTITION p201711SUB07 VALUES LESS THAN (737014) ENGINE = InnoDB,\n PARTITION p201711SUB08 VALUES LESS THAN (737016) ENGINE = InnoDB,\n PARTITION p201711SUB09 VALUES LESS THAN (737018) ENGINE = InnoDB,\n PARTITION p201711SUB10 VALUES LESS THAN (737020) ENGINE = InnoDB,\n PARTITION p201711SUB11 VALUES LESS THAN (737022) ENGINE = InnoDB,\n PARTITION p201711SUB12 VALUES LESS THAN (737024) ENGINE = InnoDB,\n PARTITION p201711SUB13 VALUES LESS THAN (737026) ENGINE = InnoDB,\n PARTITION p201711SUB14 VALUES LESS THAN (737028) ENGINE = InnoDB,\n PARTITION p201712SUB00 VALUES LESS THAN (737030) ENGINE = InnoDB,\n PARTITION p201712SUB01 VALUES LESS THAN (737032) ENGINE = InnoDB,\n PARTITION p201712SUB02 VALUES LESS THAN (737034) ENGINE = InnoDB,\n PARTITION p201712SUB03 VALUES LESS THAN (737036) ENGINE = InnoDB,\n PARTITION p201712SUB04 VALUES LESS THAN (737038) ENGINE = InnoDB,\n PARTITION p201712SUB05 VALUES LESS THAN (737040) ENGINE = InnoDB,\n PARTITION p201712SUB06 VALUES LESS THAN (737042) ENGINE = InnoDB,\n PARTITION p201712SUB07 VALUES LESS THAN (737044) ENGINE = InnoDB,\n PARTITION p201712SUB08 VALUES LESS THAN (737046) ENGINE = InnoDB,\n PARTITION p201712SUB09 VALUES LESS THAN (737048) ENGINE = InnoDB,\n PARTITION p201712SUB10 VALUES LESS THAN (737050) ENGINE = InnoDB,\n PARTITION p201712SUB11 VALUES LESS THAN (737052) ENGINE = InnoDB,\n PARTITION p201712SUB12 VALUES LESS THAN (737054) ENGINE = InnoDB,\n PARTITION p201712SUB13 VALUES LESS THAN (737056) ENGINE = InnoDB,\n PARTITION p201712SUB14 VALUES LESS THAN (737058) ENGINE = InnoDB,\n PARTITION p201801SUB00 VALUES LESS THAN (737061) ENGINE = InnoDB,\n PARTITION p201801SUB01 VALUES LESS THAN (737063) ENGINE = InnoDB,\n PARTITION p201801SUB02 VALUES LESS THAN (737065) ENGINE = InnoDB,\n PARTITION p201801SUB03 VALUES LESS THAN (737067) ENGINE = InnoDB,\n PARTITION p201801SUB04 VALUES LESS THAN (737069) ENGINE = InnoDB,\n PARTITION p201801SUB05 VALUES LESS THAN (737071) ENGINE = InnoDB,\n PARTITION p201801SUB06 VALUES LESS THAN (737073) ENGINE = InnoDB,\n PARTITION p201801SUB07 VALUES LESS THAN (737075) ENGINE = InnoDB,\n PARTITION p201801SUB08 VALUES LESS THAN (737077) ENGINE = InnoDB,\n PARTITION p201801SUB09 VALUES LESS THAN (737079) ENGINE = InnoDB,\n PARTITION p201801SUB10 VALUES LESS THAN (737081) ENGINE = InnoDB,\n PARTITION p201801SUB11 VALUES LESS THAN (737083) ENGINE = InnoDB,\n PARTITION p201801SUB12 VALUES LESS THAN (737085) ENGINE = InnoDB,\n PARTITION p201801SUB13 VALUES LESS THAN (737087) ENGINE = InnoDB,\n PARTITION p201801SUB14 VALUES LESS THAN (737089) ENGINE = InnoDB,\n PARTITION p201802SUB00 VALUES LESS THAN (737092) ENGINE = InnoDB,\n PARTITION p201802SUB01 VALUES LESS THAN (737094) ENGINE = InnoDB,\n PARTITION p201802SUB02 VALUES LESS THAN (737096) ENGINE = InnoDB,\n PARTITION p201802SUB03 VALUES LESS THAN (737098) ENGINE = InnoDB,\n PARTITION p201802SUB04 VALUES LESS THAN (737100) ENGINE = InnoDB,\n PARTITION p201802SUB05 VALUES LESS THAN (737102) ENGINE = InnoDB,\n PARTITION p201802SUB06 VALUES LESS THAN (737104) ENGINE = InnoDB,\n PARTITION p201802SUB07 VALUES LESS THAN (737106) ENGINE = InnoDB,\n PARTITION p201802SUB08 VALUES LESS THAN (737108) ENGINE = InnoDB,\n PARTITION p201802SUB09 VALUES LESS THAN (737110) ENGINE = InnoDB,\n PARTITION p201802SUB10 VALUES LESS THAN (737112) ENGINE = InnoDB,\n PARTITION p201802SUB11 VALUES LESS THAN (737114) ENGINE = InnoDB,\n PARTITION p201802SUB12 VALUES LESS THAN (737116) ENGINE = InnoDB,\n PARTITION p201802SUB13 VALUES LESS THAN (737118) ENGINE = InnoDB,\n PARTITION p201803SUB00 VALUES LESS THAN (737120) ENGINE = InnoDB,\n PARTITION p201803SUB01 VALUES LESS THAN (737122) ENGINE = InnoDB,\n PARTITION p201803SUB02 VALUES LESS THAN (737124) ENGINE = InnoDB,\n PARTITION p201803SUB03 VALUES LESS THAN (737126) ENGINE = InnoDB,\n PARTITION p201803SUB04 VALUES LESS THAN (737128) ENGINE = InnoDB,\n PARTITION p201803SUB05 VALUES LESS THAN (737130) ENGINE = InnoDB,\n PARTITION p201803SUB06 VALUES LESS THAN (737132) ENGINE = InnoDB,\n PARTITION p201803SUB07 VALUES LESS THAN (737134) ENGINE = InnoDB,\n PARTITION p201803SUB08 VALUES LESS THAN (737136) ENGINE = InnoDB,\n PARTITION p201803SUB09 VALUES LESS THAN (737138) ENGINE = InnoDB,\n PARTITION p201803SUB10 VALUES LESS THAN (737140) ENGINE = InnoDB,\n PARTITION p201803SUB11 VALUES LESS THAN (737142) ENGINE = InnoDB,\n PARTITION p201803SUB12 VALUES LESS THAN (737144) ENGINE = InnoDB,\n PARTITION p201803SUB13 VALUES LESS THAN (737146) ENGINE = InnoDB,\n PARTITION p201803SUB14 VALUES LESS THAN (737148) ENGINE = InnoDB,\n PARTITION p201804SUB00 VALUES LESS THAN (737151) ENGINE = InnoDB,\n PARTITION p201804SUB01 VALUES LESS THAN (737153) ENGINE = InnoDB,\n PARTITION p201804SUB02 VALUES LESS THAN (737155) ENGINE = InnoDB,\n PARTITION p201804SUB03 VALUES LESS THAN (737157) ENGINE = InnoDB,\n PARTITION p201804SUB04 VALUES LESS THAN (737159) ENGINE = InnoDB,\n PARTITION p201804SUB05 VALUES LESS THAN (737161) ENGINE = InnoDB,\n PARTITION p201804SUB06 VALUES LESS THAN (737163) ENGINE = InnoDB,\n PARTITION p201804SUB07 VALUES LESS THAN (737165) ENGINE = InnoDB,\n PARTITION p201804SUB08 VALUES LESS THAN (737167) ENGINE = InnoDB,\n PARTITION p201804SUB09 VALUES LESS THAN (737169) ENGINE = InnoDB,\n PARTITION p201804SUB10 VALUES LESS THAN (737171) ENGINE = InnoDB,\n PARTITION p201804SUB11 VALUES LESS THAN (737173) ENGINE = InnoDB,\n PARTITION p201804SUB12 VALUES LESS THAN (737175) ENGINE = InnoDB,\n PARTITION p201804SUB13 VALUES LESS THAN (737177) ENGINE = InnoDB,\n PARTITION p201804SUB14 VALUES LESS THAN (737179) ENGINE = InnoDB,\n PARTITION p201805SUB00 VALUES LESS THAN (737181) ENGINE = InnoDB,\n PARTITION p201805SUB01 VALUES LESS THAN (737183) ENGINE = InnoDB,\n PARTITION p201805SUB02 VALUES LESS THAN (737185) ENGINE = InnoDB,\n PARTITION p201805SUB03 VALUES LESS THAN (737187) ENGINE = InnoDB,\n PARTITION p201805SUB04 VALUES LESS THAN (737189) ENGINE = InnoDB,\n PARTITION p201805SUB05 VALUES LESS THAN (737191) ENGINE = InnoDB,\n PARTITION p201805SUB06 VALUES LESS THAN (737193) ENGINE = InnoDB,\n PARTITION p201805SUB07 VALUES LESS THAN (737195) ENGINE = InnoDB,\n PARTITION p201805SUB08 VALUES LESS THAN (737197) ENGINE = InnoDB,\n PARTITION p201805SUB09 VALUES LESS THAN (737199) ENGINE = InnoDB,\n PARTITION p201805SUB10 VALUES LESS THAN (737201) ENGINE = InnoDB,\n PARTITION p201805SUB11 VALUES LESS THAN (737203) ENGINE = InnoDB,\n PARTITION p201805SUB12 VALUES LESS THAN (737205) ENGINE = InnoDB,\n PARTITION p201805SUB13 VALUES LESS THAN (737207) ENGINE = InnoDB,\n PARTITION p201805SUB14 VALUES LESS THAN (737209) ENGINE = InnoDB,\n PARTITION p201806SUB00 VALUES LESS THAN (737212) ENGINE = InnoDB,\n PARTITION p201806SUB01 VALUES LESS THAN (737214) ENGINE = InnoDB,\n PARTITION p201806SUB02 VALUES LESS THAN (737216) ENGINE = InnoDB,\n PARTITION p201806SUB03 VALUES LESS THAN (737218) ENGINE = InnoDB,\n PARTITION p201806SUB04 VALUES LESS THAN (737220) ENGINE = InnoDB,\n PARTITION p201806SUB05 VALUES LESS THAN (737222) ENGINE = InnoDB,\n PARTITION p201806SUB06 VALUES LESS THAN (737224) ENGINE = InnoDB,\n PARTITION p201806SUB07 VALUES LESS THAN (737226) ENGINE = InnoDB,\n PARTITION p201806SUB08 VALUES LESS THAN (737228) ENGINE = InnoDB,\n PARTITION p201806SUB09 VALUES LESS THAN (737230) ENGINE = InnoDB,\n PARTITION p201806SUB10 VALUES LESS THAN (737232) ENGINE = InnoDB,\n PARTITION p201806SUB11 VALUES LESS THAN (737234) ENGINE = InnoDB,\n PARTITION p201806SUB12 VALUES LESS THAN (737236) ENGINE = InnoDB,\n PARTITION p201806SUB13 VALUES LESS THAN (737238) ENGINE = InnoDB,\n PARTITION p201806SUB14 VALUES LESS THAN (737240) ENGINE = InnoDB,\n PARTITION p201807SUB00 VALUES LESS THAN (737242) ENGINE = InnoDB,\n PARTITION p201807SUB01 VALUES LESS THAN (737244) ENGINE = InnoDB,\n PARTITION p201807SUB02 VALUES LESS THAN (737246) ENGINE = InnoDB,\n PARTITION p201807SUB03 VALUES LESS THAN (737248) ENGINE = InnoDB,\n PARTITION p201807SUB04 VALUES LESS THAN (737250) ENGINE = InnoDB,\n PARTITION p201807SUB05 VALUES LESS THAN (737252) ENGINE = InnoDB,\n PARTITION p201807SUB06 VALUES LESS THAN (737254) ENGINE = InnoDB,\n PARTITION p201807SUB07 VALUES LESS THAN (737256) ENGINE = InnoDB,\n PARTITION p201807SUB08 VALUES LESS THAN (737258) ENGINE = InnoDB,\n PARTITION p201807SUB09 VALUES LESS THAN (737260) ENGINE = InnoDB,\n PARTITION p201807SUB10 VALUES LESS THAN (737262) ENGINE = InnoDB,\n PARTITION p201807SUB11 VALUES LESS THAN (737264) ENGINE = InnoDB,\n PARTITION p201807SUB12 VALUES LESS THAN (737266) ENGINE = InnoDB,\n PARTITION p201807SUB13 VALUES LESS THAN (737268) ENGINE = InnoDB,\n PARTITION p201807SUB14 VALUES LESS THAN (737270) ENGINE = InnoDB,\n PARTITION p201808SUB00 VALUES LESS THAN (737273) ENGINE = InnoDB,\n PARTITION p201808SUB01 VALUES LESS THAN (737275) ENGINE = InnoDB,\n PARTITION p201808SUB02 VALUES LESS THAN (737277) ENGINE = InnoDB,\n PARTITION p201808SUB03 VALUES LESS THAN (737279) ENGINE = InnoDB,\n PARTITION p201808SUB04 VALUES LESS THAN (737281) ENGINE = InnoDB,\n PARTITION p201808SUB05 VALUES LESS THAN (737283) ENGINE = InnoDB,\n PARTITION p201808SUB06 VALUES LESS THAN (737285) ENGINE = InnoDB,\n PARTITION p201808SUB07 VALUES LESS THAN (737287) ENGINE = InnoDB,\n PARTITION p201808SUB08 VALUES LESS THAN (737289) ENGINE = InnoDB,\n PARTITION p201808SUB09 VALUES LESS THAN (737291) ENGINE = InnoDB,\n PARTITION p201808SUB10 VALUES LESS THAN (737293) ENGINE = InnoDB,\n PARTITION p201808SUB11 VALUES LESS THAN (737295) ENGINE = InnoDB,\n PARTITION p201808SUB12 VALUES LESS THAN (737297) ENGINE = InnoDB,\n PARTITION p201808SUB13 VALUES LESS THAN (737299) ENGINE = InnoDB,\n PARTITION p201808SUB14 VALUES LESS THAN (737301) ENGINE = InnoDB,\n PARTITION p201809SUB00 VALUES LESS THAN (737304) ENGINE = InnoDB,\n PARTITION p201809SUB01 VALUES LESS THAN (737306) ENGINE = InnoDB,\n PARTITION p201809SUB02 VALUES LESS THAN (737308) ENGINE = InnoDB,\n PARTITION p201809SUB03 VALUES LESS THAN (737310) ENGINE = InnoDB,\n PARTITION p201809SUB04 VALUES LESS THAN (737312) ENGINE = InnoDB,\n PARTITION p201809SUB05 VALUES LESS THAN (737314) ENGINE = InnoDB,\n PARTITION p201809SUB06 VALUES LESS THAN (737316) ENGINE = InnoDB,\n PARTITION p201809SUB07 VALUES LESS THAN (737318) ENGINE = InnoDB,\n PARTITION p201809SUB08 VALUES LESS THAN (737320) ENGINE = InnoDB,\n PARTITION p201809SUB09 VALUES LESS THAN (737322) ENGINE = InnoDB,\n PARTITION p201809SUB10 VALUES LESS THAN (737324) ENGINE = InnoDB,\n PARTITION p201809SUB11 VALUES LESS THAN (737326) ENGINE = InnoDB,\n PARTITION p201809SUB12 VALUES LESS THAN (737328) ENGINE = InnoDB,\n PARTITION p201809SUB13 VALUES LESS THAN (737330) ENGINE = InnoDB,\n PARTITION p201809SUB14 VALUES LESS THAN (737332) ENGINE = InnoDB,\n PARTITION p201810SUB00 VALUES LESS THAN (737334) ENGINE = InnoDB,\n PARTITION p201810SUB01 VALUES LESS THAN (737336) ENGINE = InnoDB,\n PARTITION p201810SUB02 VALUES LESS THAN (737338) ENGINE = InnoDB,\n PARTITION p201810SUB03 VALUES LESS THAN (737340) ENGINE = InnoDB,\n PARTITION p201810SUB04 VALUES LESS THAN (737342) ENGINE = InnoDB,\n PARTITION p201810SUB05 VALUES LESS THAN (737344) ENGINE = InnoDB,\n PARTITION p201810SUB06 VALUES LESS THAN (737346) ENGINE = InnoDB,\n PARTITION p201810SUB07 VALUES LESS THAN (737348) ENGINE = InnoDB,\n PARTITION p201810SUB08 VALUES LESS THAN (737350) ENGINE = InnoDB,\n PARTITION p201810SUB09 VALUES LESS THAN (737352) ENGINE = InnoDB,\n PARTITION p201810SUB10 VALUES LESS THAN (737354) ENGINE = InnoDB,\n PARTITION p201810SUB11 VALUES LESS THAN (737356) ENGINE = InnoDB,\n PARTITION p201810SUB12 VALUES LESS THAN (737358) ENGINE = InnoDB,\n PARTITION p201810SUB13 VALUES LESS THAN (737360) ENGINE = InnoDB,\n PARTITION p201810SUB14 VALUES LESS THAN (737362) ENGINE = InnoDB,\n PARTITION p201811SUB00 VALUES LESS THAN (737365) ENGINE = InnoDB,\n PARTITION p201811SUB01 VALUES LESS THAN (737367) ENGINE = InnoDB,\n PARTITION p201811SUB02 VALUES LESS THAN (737369) ENGINE = InnoDB,\n PARTITION p201811SUB03 VALUES LESS THAN (737371) ENGINE = InnoDB,\n PARTITION p201811SUB04 VALUES LESS THAN (737373) ENGINE = InnoDB,\n PARTITION p201811SUB05 VALUES LESS THAN (737375) ENGINE = InnoDB,\n PARTITION p201811SUB06 VALUES LESS THAN (737377) ENGINE = InnoDB,\n PARTITION p201811SUB07 VALUES LESS THAN (737379) ENGINE = InnoDB,\n PARTITION p201811SUB08 VALUES LESS THAN (737381) ENGINE = InnoDB,\n PARTITION p201811SUB09 VALUES LESS THAN (737383) ENGINE = InnoDB,\n PARTITION p201811SUB10 VALUES LESS THAN (737385) ENGINE = InnoDB,\n PARTITION p201811SUB11 VALUES LESS THAN (737387) ENGINE = InnoDB,\n PARTITION p201811SUB12 VALUES LESS THAN (737389) ENGINE = InnoDB,\n PARTITION p201811SUB13 VALUES LESS THAN (737391) ENGINE = InnoDB,\n PARTITION p201811SUB14 VALUES LESS THAN (737393) ENGINE = InnoDB,\n PARTITION p201812SUB00 VALUES LESS THAN (737395) ENGINE = InnoDB,\n PARTITION p201812SUB01 VALUES LESS THAN (737397) ENGINE = InnoDB,\n PARTITION p201812SUB02 VALUES LESS THAN (737399) ENGINE = InnoDB,\n PARTITION p201812SUB03 VALUES LESS THAN (737401) ENGINE = InnoDB,\n PARTITION p201812SUB04 VALUES LESS THAN (737403) ENGINE = InnoDB,\n PARTITION p201812SUB05 VALUES LESS THAN (737405) ENGINE = InnoDB,\n PARTITION p201812SUB06 VALUES LESS THAN (737407) ENGINE = InnoDB,\n PARTITION p201812SUB07 VALUES LESS THAN (737409) ENGINE = InnoDB,\n PARTITION p201812SUB08 VALUES LESS THAN (737411) ENGINE = InnoDB,\n PARTITION p201812SUB09 VALUES LESS THAN (737413) ENGINE = InnoDB,\n PARTITION p201812SUB10 VALUES LESS THAN (737415) ENGINE = InnoDB,\n PARTITION p201812SUB11 VALUES LESS THAN (737417) ENGINE = InnoDB,\n PARTITION p201812SUB12 VALUES LESS THAN (737419) ENGINE = InnoDB,\n PARTITION p201812SUB13 VALUES LESS THAN (737421) ENGINE = InnoDB,\n PARTITION p201812SUB14 VALUES LESS THAN (737423) ENGINE = InnoDB,\n PARTITION p201901SUB00 VALUES LESS THAN (737426) ENGINE = InnoDB,\n PARTITION p201901SUB01 VALUES LESS THAN (737428) ENGINE = InnoDB,\n PARTITION p201901SUB02 VALUES LESS THAN (737430) ENGINE = InnoDB,\n PARTITION p201901SUB03 VALUES LESS THAN (737432) ENGINE = InnoDB,\n PARTITION p201901SUB04 VALUES LESS THAN (737434) ENGINE = InnoDB,\n PARTITION p201901SUB05 VALUES LESS THAN (737436) ENGINE = InnoDB,\n PARTITION p201901SUB06 VALUES LESS THAN (737438) ENGINE = InnoDB,\n PARTITION p201901SUB07 VALUES LESS THAN (737440) ENGINE = InnoDB,\n PARTITION p201901SUB08 VALUES LESS THAN (737442) ENGINE = InnoDB,\n PARTITION p201901SUB09 VALUES LESS THAN (737444) ENGINE = InnoDB,\n PARTITION p201901SUB10 VALUES LESS THAN (737446) ENGINE = InnoDB,\n PARTITION p201901SUB11 VALUES LESS THAN (737448) ENGINE = InnoDB,\n PARTITION p201901SUB12 VALUES LESS THAN (737450) ENGINE = InnoDB,\n PARTITION p201901SUB13 VALUES LESS THAN (737452) ENGINE = InnoDB,\n PARTITION p201901SUB14 VALUES LESS THAN (737454) ENGINE = InnoDB,\n PARTITION p201902SUB00 VALUES LESS THAN (737457) ENGINE = InnoDB,\n PARTITION p201902SUB01 VALUES LESS THAN (737459) ENGINE = InnoDB,\n PARTITION p201902SUB02 VALUES LESS THAN (737461) ENGINE = InnoDB,\n PARTITION p201902SUB03 VALUES LESS THAN (737463) ENGINE = InnoDB,\n PARTITION p201902SUB04 VALUES LESS THAN (737465) ENGINE = InnoDB,\n PARTITION p201902SUB05 VALUES LESS THAN (737467) ENGINE = InnoDB,\n PARTITION p201902SUB06 VALUES LESS THAN (737469) ENGINE = InnoDB,\n PARTITION p201902SUB07 VALUES LESS THAN (737471) ENGINE = InnoDB,\n PARTITION p201902SUB08 VALUES LESS THAN (737473) ENGINE = InnoDB,\n PARTITION p201902SUB09 VALUES LESS THAN (737475) ENGINE = InnoDB,\n PARTITION p201902SUB10 VALUES LESS THAN (737477) ENGINE = InnoDB,\n PARTITION p201902SUB11 VALUES LESS THAN (737479) ENGINE = InnoDB,\n PARTITION p201902SUB12 VALUES LESS THAN (737481) ENGINE = InnoDB,\n PARTITION p201902SUB13 VALUES LESS THAN (737483) ENGINE = InnoDB,\n PARTITION p201903SUB00 VALUES LESS THAN (737485) ENGINE = InnoDB,\n PARTITION p201903SUB01 VALUES LESS THAN (737487) ENGINE = InnoDB,\n PARTITION p201903SUB02 VALUES LESS THAN (737489) ENGINE = InnoDB,\n PARTITION p201903SUB03 VALUES LESS THAN (737491) ENGINE = InnoDB,\n PARTITION p201903SUB04 VALUES LESS THAN (737493) ENGINE = InnoDB,\n PARTITION p201903SUB05 VALUES LESS THAN (737495) ENGINE = InnoDB,\n PARTITION p201903SUB06 VALUES LESS THAN (737497) ENGINE = InnoDB,\n PARTITION p201903SUB07 VALUES LESS THAN (737499) ENGINE = InnoDB,\n PARTITION p201903SUB08 VALUES LESS THAN (737501) ENGINE = InnoDB,\n PARTITION p201903SUB09 VALUES LESS THAN (737503) ENGINE = InnoDB,\n PARTITION p201903SUB10 VALUES LESS THAN (737505) ENGINE = InnoDB,\n PARTITION p201903SUB11 VALUES LESS THAN (737507) ENGINE = InnoDB,\n PARTITION p201903SUB12 VALUES LESS THAN (737509) ENGINE = InnoDB,\n PARTITION p201903SUB13 VALUES LESS THAN (737511) ENGINE = InnoDB,\n PARTITION p201903SUB14 VALUES LESS THAN (737513) ENGINE = InnoDB,\n PARTITION p201904SUB00 VALUES LESS THAN (737516) ENGINE = InnoDB,\n PARTITION p201904SUB01 VALUES LESS THAN (737518) ENGINE = InnoDB,\n PARTITION p201904SUB02 VALUES LESS THAN (737520) ENGINE = InnoDB,\n PARTITION p201904SUB03 VALUES LESS THAN (737522) ENGINE = InnoDB,\n PARTITION p201904SUB04 VALUES LESS THAN (737524) ENGINE = InnoDB,\n PARTITION p201904SUB05 VALUES LESS THAN (737526) ENGINE = InnoDB,\n PARTITION p201904SUB06 VALUES LESS THAN (737528) ENGINE = InnoDB,\n PARTITION p201904SUB07 VALUES LESS THAN (737530) ENGINE = InnoDB,\n PARTITION p201904SUB08 VALUES LESS THAN (737532) ENGINE = InnoDB,\n PARTITION p201904SUB09 VALUES LESS THAN (737534) ENGINE = InnoDB,\n PARTITION p201904SUB10 VALUES LESS THAN (737536) ENGINE = InnoDB,\n PARTITION p201904SUB11 VALUES LESS THAN (737538) ENGINE = InnoDB,\n PARTITION p201904SUB12 VALUES LESS THAN (737540) ENGINE = InnoDB,\n PARTITION p201904SUB13 VALUES LESS THAN (737542) ENGINE = InnoDB,\n PARTITION p201904SUB14 VALUES LESS THAN (737544) ENGINE = InnoDB,\n PARTITION p201905SUB00 VALUES LESS THAN (737546) ENGINE = InnoDB,\n PARTITION p201905SUB01 VALUES LESS THAN (737548) ENGINE = InnoDB,\n PARTITION p201905SUB02 VALUES LESS THAN (737550) ENGINE = InnoDB,\n PARTITION p201905SUB03 VALUES LESS THAN (737552) ENGINE = InnoDB,\n PARTITION p201905SUB04 VALUES LESS THAN (737554) ENGINE = InnoDB,\n PARTITION p201905SUB05 VALUES LESS THAN (737556) ENGINE = InnoDB,\n PARTITION p201905SUB06 VALUES LESS THAN (737558) ENGINE = InnoDB,\n PARTITION p201905SUB07 VALUES LESS THAN (737560) ENGINE = InnoDB,\n PARTITION p201905SUB08 VALUES LESS THAN (737562) ENGINE = InnoDB,\n PARTITION p201905SUB09 VALUES LESS THAN (737564) ENGINE = InnoDB,\n PARTITION p201905SUB10 VALUES LESS THAN (737566) ENGINE = InnoDB,\n PARTITION p201905SUB11 VALUES LESS THAN (737568) ENGINE = InnoDB,\n PARTITION p201905SUB12 VALUES LESS THAN (737570) ENGINE = InnoDB,\n PARTITION p201905SUB13 VALUES LESS THAN (737572) ENGINE = InnoDB,\n PARTITION p201905SUB14 VALUES LESS THAN (737574) ENGINE = InnoDB,\n PARTITION p201906SUB00 VALUES LESS THAN (737577) ENGINE = InnoDB,\n PARTITION p201906SUB01 VALUES LESS THAN (737579) ENGINE = InnoDB,\n PARTITION p201906SUB02 VALUES LESS THAN (737581) ENGINE = InnoDB,\n PARTITION p201906SUB03 VALUES LESS THAN (737583) ENGINE = InnoDB,\n PARTITION p201906SUB04 VALUES LESS THAN (737585) ENGINE = InnoDB,\n PARTITION p201906SUB05 VALUES LESS THAN (737587) ENGINE = InnoDB,\n PARTITION p201906SUB06 VALUES LESS THAN (737589) ENGINE = InnoDB,\n PARTITION p201906SUB07 VALUES LESS THAN (737591) ENGINE = InnoDB,\n PARTITION p201906SUB08 VALUES LESS THAN (737593) ENGINE = InnoDB,\n PARTITION p201906SUB09 VALUES LESS THAN (737595) ENGINE = InnoDB,\n PARTITION p201906SUB10 VALUES LESS THAN (737597) ENGINE = InnoDB,\n PARTITION p201906SUB11 VALUES LESS THAN (737599) ENGINE = InnoDB,\n PARTITION p201906SUB12 VALUES LESS THAN (737601) ENGINE = InnoDB,\n PARTITION p201906SUB13 VALUES LESS THAN (737603) ENGINE = InnoDB,\n PARTITION p201906SUB14 VALUES LESS THAN (737605) ENGINE = InnoDB,\n PARTITION p201907SUB00 VALUES LESS THAN (737607) ENGINE = InnoDB,\n PARTITION p201907SUB01 VALUES LESS THAN (737609) ENGINE = InnoDB,\n PARTITION p201907SUB02 VALUES LESS THAN (737611) ENGINE = InnoDB,\n PARTITION p201907SUB03 VALUES LESS THAN (737613) ENGINE = InnoDB,\n PARTITION p201907SUB04 VALUES LESS THAN (737615) ENGINE = InnoDB,\n PARTITION p201907SUB05 VALUES LESS THAN (737617) ENGINE = InnoDB,\n PARTITION p201907SUB06 VALUES LESS THAN (737619) ENGINE = InnoDB,\n PARTITION p201907SUB07 VALUES LESS THAN (737621) ENGINE = InnoDB,\n PARTITION p201907SUB08 VALUES LESS THAN (737623) ENGINE = InnoDB,\n PARTITION p201907SUB09 VALUES LESS THAN (737625) ENGINE = InnoDB,\n PARTITION p201907SUB10 VALUES LESS THAN (737627) ENGINE = InnoDB,\n PARTITION p201907SUB11 VALUES LESS THAN (737629) ENGINE = InnoDB,\n PARTITION p201907SUB12 VALUES LESS THAN (737631) ENGINE = InnoDB,\n PARTITION p201907SUB13 VALUES LESS THAN (737633) ENGINE = InnoDB,\n PARTITION p201907SUB14 VALUES LESS THAN (737635) ENGINE = InnoDB,\n PARTITION p201908SUB00 VALUES LESS THAN (737638) ENGINE = InnoDB,\n PARTITION p201908SUB01 VALUES LESS THAN (737640) ENGINE = InnoDB,\n PARTITION p201908SUB02 VALUES LESS THAN (737642) ENGINE = InnoDB,\n PARTITION p201908SUB03 VALUES LESS THAN (737644) ENGINE = InnoDB,\n PARTITION p201908SUB04 VALUES LESS THAN (737646) ENGINE = InnoDB,\n PARTITION p201908SUB05 VALUES LESS THAN (737648) ENGINE = InnoDB,\n PARTITION p201908SUB06 VALUES LESS THAN (737650) ENGINE = InnoDB,\n PARTITION p201908SUB07 VALUES LESS THAN (737652) ENGINE = InnoDB,\n PARTITION p201908SUB08 VALUES LESS THAN (737654) ENGINE = InnoDB,\n PARTITION p201908SUB09 VALUES LESS THAN (737656) ENGINE = InnoDB,\n PARTITION p201908SUB10 VALUES LESS THAN (737658) ENGINE = InnoDB,\n PARTITION p201908SUB11 VALUES LESS THAN (737660) ENGINE = InnoDB,\n PARTITION p201908SUB12 VALUES LESS THAN (737662) ENGINE = InnoDB,\n PARTITION p201908SUB13 VALUES LESS THAN (737664) ENGINE = InnoDB,\n PARTITION p201908SUB14 VALUES LESS THAN (737666) ENGINE = InnoDB,\n PARTITION p201909SUB00 VALUES LESS THAN (737669) ENGINE = InnoDB,\n PARTITION p201909SUB01 VALUES LESS THAN (737671) ENGINE = InnoDB,\n PARTITION p201909SUB02 VALUES LESS THAN (737673) ENGINE = InnoDB,\n PARTITION p201909SUB03 VALUES LESS THAN (737675) ENGINE = InnoDB,\n PARTITION p201909SUB04 VALUES LESS THAN (737677) ENGINE = InnoDB,\n PARTITION p201909SUB05 VALUES LESS THAN (737679) ENGINE = InnoDB,\n PARTITION p201909SUB06 VALUES LESS THAN (737681) ENGINE = InnoDB,\n PARTITION p201909SUB07 VALUES LESS THAN (737683) ENGINE = InnoDB,\n PARTITION p201909SUB08 VALUES LESS THAN (737685) ENGINE = InnoDB,\n PARTITION p201909SUB09 VALUES LESS THAN (737687) ENGINE = InnoDB,\n PARTITION p201909SUB10 VALUES LESS THAN (737689) ENGINE = InnoDB,\n PARTITION p201909SUB11 VALUES LESS THAN (737691) ENGINE = InnoDB,\n PARTITION p201909SUB12 VALUES LESS THAN (737693) ENGINE = InnoDB,\n PARTITION p201909SUB13 VALUES LESS THAN (737695) ENGINE = InnoDB,\n PARTITION p201909SUB14 VALUES LESS THAN (737697) ENGINE = InnoDB,\n PARTITION p201910SUB00 VALUES LESS THAN (737699) ENGINE = InnoDB,\n PARTITION p201910SUB01 VALUES LESS THAN (737701) ENGINE = InnoDB,\n PARTITION p201910SUB02 VALUES LESS THAN (737703) ENGINE = InnoDB,\n PARTITION p201910SUB03 VALUES LESS THAN (737705) ENGINE = InnoDB,\n PARTITION p201910SUB04 VALUES LESS THAN (737707) ENGINE = InnoDB,\n PARTITION p201910SUB05 VALUES LESS THAN (737709) ENGINE = InnoDB,\n PARTITION p201910SUB06 VALUES LESS THAN (737711) ENGINE = InnoDB,\n PARTITION p201910SUB07 VALUES LESS THAN (737713) ENGINE = InnoDB,\n PARTITION p201910SUB08 VALUES LESS THAN (737715) ENGINE = InnoDB,\n PARTITION p201910SUB09 VALUES LESS THAN (737717) ENGINE = InnoDB,\n PARTITION p201910SUB10 VALUES LESS THAN (737719) ENGINE = InnoDB,\n PARTITION p201910SUB11 VALUES LESS THAN (737721) ENGINE = InnoDB,\n PARTITION p201910SUB12 VALUES LESS THAN (737723) ENGINE = InnoDB,\n PARTITION p201910SUB13 VALUES LESS THAN (737725) ENGINE = InnoDB,\n PARTITION p201910SUB14 VALUES LESS THAN (737727) ENGINE = InnoDB,\n PARTITION p201911SUB00 VALUES LESS THAN (737730) ENGINE = InnoDB,\n PARTITION p201911SUB01 VALUES LESS THAN (737732) ENGINE = InnoDB,\n PARTITION p201911SUB02 VALUES LESS THAN (737734) ENGINE = InnoDB,\n PARTITION p201911SUB03 VALUES LESS THAN (737736) ENGINE = InnoDB,\n PARTITION p201911SUB04 VALUES LESS THAN (737738) ENGINE = InnoDB,\n PARTITION p201911SUB05 VALUES LESS THAN (737740) ENGINE = InnoDB,\n PARTITION p201911SUB06 VALUES LESS THAN (737742) ENGINE = InnoDB,\n PARTITION p201911SUB07 VALUES LESS THAN (737744) ENGINE = InnoDB,\n PARTITION p201911SUB08 VALUES LESS THAN (737746) ENGINE = InnoDB,\n PARTITION p201911SUB09 VALUES LESS THAN (737748) ENGINE = InnoDB,\n PARTITION p201911SUB10 VALUES LESS THAN (737750) ENGINE = InnoDB,\n PARTITION p201911SUB11 VALUES LESS THAN (737752) ENGINE = InnoDB,\n PARTITION p201911SUB12 VALUES LESS THAN (737754) ENGINE = InnoDB,\n PARTITION p201911SUB13 VALUES LESS THAN (737756) ENGINE = InnoDB,\n PARTITION p201911SUB14 VALUES LESS THAN (737758) ENGINE = InnoDB,\n PARTITION p201912SUB00 VALUES LESS THAN (737760) ENGINE = InnoDB,\n PARTITION p201912SUB01 VALUES LESS THAN (737762) ENGINE = InnoDB,\n PARTITION p201912SUB02 VALUES LESS THAN (737764) ENGINE = InnoDB,\n PARTITION p201912SUB03 VALUES LESS THAN (737766) ENGINE = InnoDB,\n PARTITION p201912SUB04 VALUES LESS THAN (737768) ENGINE = InnoDB,\n PARTITION p201912SUB05 VALUES LESS THAN (737770) ENGINE = InnoDB,\n PARTITION p201912SUB06 VALUES LESS THAN (737772) ENGINE = InnoDB,\n PARTITION p201912SUB07 VALUES LESS THAN (737774) ENGINE = InnoDB,\n PARTITION p201912SUB08 VALUES LESS THAN (737776) ENGINE = InnoDB,\n PARTITION p201912SUB09 VALUES LESS THAN (737778) ENGINE = InnoDB,\n PARTITION p201912SUB10 VALUES LESS THAN (737780) ENGINE = InnoDB,\n PARTITION p201912SUB11 VALUES LESS THAN (737782) ENGINE = InnoDB,\n PARTITION p201912SUB12 VALUES LESS THAN (737784) ENGINE = InnoDB,\n PARTITION p201912SUB13 VALUES LESS THAN (737786) ENGINE = InnoDB,\n PARTITION p201912SUB14 VALUES LESS THAN (737788) ENGINE = InnoDB,\n PARTITION p202001SUB00 VALUES LESS THAN (737791) ENGINE = InnoDB,\n PARTITION p202001SUB01 VALUES LESS THAN (737793) ENGINE = InnoDB,\n PARTITION p202001SUB02 VALUES LESS THAN (737795) ENGINE = InnoDB,\n PARTITION p202001SUB03 VALUES LESS THAN (737797) ENGINE = InnoDB,\n PARTITION p202001SUB04 VALUES LESS THAN (737799) ENGINE = InnoDB,\n PARTITION p202001SUB05 VALUES LESS THAN (737801) ENGINE = InnoDB,\n PARTITION p202001SUB06 VALUES LESS THAN (737803) ENGINE = InnoDB,\n PARTITION p202001SUB07 VALUES LESS THAN (737805) ENGINE = InnoDB,\n PARTITION p202001SUB08 VALUES LESS THAN (737807) ENGINE = InnoDB,\n PARTITION p202001SUB09 VALUES LESS THAN (737809) ENGINE = InnoDB,\n PARTITION p202001SUB10 VALUES LESS THAN (737811) ENGINE = InnoDB,\n PARTITION p202001SUB11 VALUES LESS THAN (737813) ENGINE = InnoDB,\n PARTITION p202001SUB12 VALUES LESS THAN (737815) ENGINE = InnoDB,\n PARTITION p202001SUB13 VALUES LESS THAN (737817) ENGINE = InnoDB,\n PARTITION p202001SUB14 VALUES LESS THAN (737819) ENGINE = InnoDB,\n PARTITION p202002SUB00 VALUES LESS THAN (737822) ENGINE = InnoDB,\n PARTITION p202002SUB01 VALUES LESS THAN (737824) ENGINE = InnoDB,\n PARTITION p202002SUB02 VALUES LESS THAN (737826) ENGINE = InnoDB,\n PARTITION p202002SUB03 VALUES LESS THAN (737828) ENGINE = InnoDB,\n PARTITION p202002SUB04 VALUES LESS THAN (737830) ENGINE = InnoDB,\n PARTITION p202002SUB05 VALUES LESS THAN (737832) ENGINE = InnoDB,\n PARTITION p202002SUB06 VALUES LESS THAN (737834) ENGINE = InnoDB,\n PARTITION p202002SUB07 VALUES LESS THAN (737836) ENGINE = InnoDB,\n PARTITION p202002SUB08 VALUES LESS THAN (737838) ENGINE = InnoDB,\n PARTITION p202002SUB09 VALUES LESS THAN (737840) ENGINE = InnoDB,\n PARTITION p202002SUB10 VALUES LESS THAN (737842) ENGINE = InnoDB,\n PARTITION p202002SUB11 VALUES LESS THAN (737844) ENGINE = InnoDB,\n PARTITION p202002SUB12 VALUES LESS THAN (737846) ENGINE = InnoDB,\n PARTITION p202002SUB13 VALUES LESS THAN (737848) ENGINE = InnoDB,\n PARTITION p202003SUB00 VALUES LESS THAN (737851) ENGINE = InnoDB,\n PARTITION p202003SUB01 VALUES LESS THAN (737853) ENGINE = InnoDB,\n PARTITION p202003SUB02 VALUES LESS THAN (737855) ENGINE = InnoDB,\n PARTITION p202003SUB03 VALUES LESS THAN (737857) ENGINE = InnoDB,\n PARTITION p202003SUB04 VALUES LESS THAN (737859) ENGINE = InnoDB,\n PARTITION p202003SUB05 VALUES LESS THAN (737861) ENGINE = InnoDB,\n PARTITION p202003SUB06 VALUES LESS THAN (737863) ENGINE = InnoDB,\n PARTITION p202003SUB07 VALUES LESS THAN (737865) ENGINE = InnoDB,\n PARTITION p202003SUB08 VALUES LESS THAN (737867) ENGINE = InnoDB,\n PARTITION p202003SUB09 VALUES LESS THAN (737869) ENGINE = InnoDB,\n PARTITION p202003SUB10 VALUES LESS THAN (737871) ENGINE = InnoDB,\n PARTITION p202003SUB11 VALUES LESS THAN (737873) ENGINE = InnoDB,\n PARTITION p202003SUB12 VALUES LESS THAN (737875) ENGINE = InnoDB,\n PARTITION p202003SUB13 VALUES LESS THAN (737877) ENGINE = InnoDB,\n PARTITION p202003SUB14 VALUES LESS THAN (737879) ENGINE = InnoDB,\n PARTITION p202004SUB00 VALUES LESS THAN (737882) ENGINE = InnoDB,\n PARTITION p202004SUB01 VALUES LESS THAN (737884) ENGINE = InnoDB,\n PARTITION p202004SUB02 VALUES LESS THAN (737886) ENGINE = InnoDB,\n PARTITION p202004SUB03 VALUES LESS THAN (737888) ENGINE = InnoDB,\n PARTITION p202004SUB04 VALUES LESS THAN (737890) ENGINE = InnoDB,\n PARTITION p202004SUB05 VALUES LESS THAN (737892) ENGINE = InnoDB,\n PARTITION p202004SUB06 VALUES LESS THAN (737894) ENGINE = InnoDB,\n PARTITION p202004SUB07 VALUES LESS THAN (737896) ENGINE = InnoDB,\n PARTITION p202004SUB08 VALUES LESS THAN (737898) ENGINE = InnoDB,\n PARTITION p202004SUB09 VALUES LESS THAN (737900) ENGINE = InnoDB,\n PARTITION p202004SUB10 VALUES LESS THAN (737902) ENGINE = InnoDB,\n PARTITION p202004SUB11 VALUES LESS THAN (737904) ENGINE = InnoDB,\n PARTITION p202004SUB12 VALUES LESS THAN (737906) ENGINE = InnoDB,\n PARTITION p202004SUB13 VALUES LESS THAN (737908) ENGINE = InnoDB,\n PARTITION p202004SUB14 VALUES LESS THAN (737910) ENGINE = InnoDB,\n PARTITION p202005SUB00 VALUES LESS THAN (737912) ENGINE = InnoDB,\n PARTITION p202005SUB01 VALUES LESS THAN (737914) ENGINE = InnoDB,\n PARTITION p202005SUB02 VALUES LESS THAN (737916) ENGINE = InnoDB,\n PARTITION p202005SUB03 VALUES LESS THAN (737918) ENGINE = InnoDB,\n PARTITION p202005SUB04 VALUES LESS THAN (737920) ENGINE = InnoDB,\n PARTITION p202005SUB05 VALUES LESS THAN (737922) ENGINE = InnoDB,\n PARTITION p202005SUB06 VALUES LESS THAN (737924) ENGINE = InnoDB,\n PARTITION p202005SUB07 VALUES LESS THAN (737926) ENGINE = InnoDB,\n PARTITION p202005SUB08 VALUES LESS THAN (737928) ENGINE = InnoDB,\n PARTITION p202005SUB09 VALUES LESS THAN (737930) ENGINE = InnoDB,\n PARTITION p202005SUB10 VALUES LESS THAN (737932) ENGINE = InnoDB,\n PARTITION p202005SUB11 VALUES LESS THAN (737934) ENGINE = InnoDB,\n PARTITION p202005SUB12 VALUES LESS THAN (737936) ENGINE = InnoDB,\n PARTITION p202005SUB13 VALUES LESS THAN (737938) ENGINE = InnoDB,\n PARTITION p202005SUB14 VALUES LESS THAN (737940) ENGINE = InnoDB,\n PARTITION p202006SUB00 VALUES LESS THAN (737943) ENGINE = InnoDB,\n PARTITION p202006SUB01 VALUES LESS THAN (737945) ENGINE = InnoDB,\n PARTITION p202006SUB02 VALUES LESS THAN (737947) ENGINE = InnoDB,\n PARTITION p202006SUB03 VALUES LESS THAN (737949) ENGINE = InnoDB,\n PARTITION p202006SUB04 VALUES LESS THAN (737951) ENGINE = InnoDB,\n PARTITION p202006SUB05 VALUES LESS THAN (737953) ENGINE = InnoDB,\n PARTITION p202006SUB06 VALUES LESS THAN (737955) ENGINE = InnoDB,\n PARTITION p202006SUB07 VALUES LESS THAN (737957) ENGINE = InnoDB,\n PARTITION p202006SUB08 VALUES LESS THAN (737959) ENGINE = InnoDB,\n PARTITION p202006SUB09 VALUES LESS THAN (737961) ENGINE = InnoDB,\n PARTITION p202006SUB10 VALUES LESS THAN (737963) ENGINE = InnoDB,\n PARTITION p202006SUB11 VALUES LESS THAN (737965) ENGINE = InnoDB,\n PARTITION p202006SUB12 VALUES LESS THAN (737967) ENGINE = InnoDB,\n PARTITION p202006SUB13 VALUES LESS THAN (737969) ENGINE = InnoDB,\n PARTITION p202006SUB14 VALUES LESS THAN (737971) ENGINE = InnoDB,\n PARTITION p202007SUB00 VALUES LESS THAN (737973) ENGINE = InnoDB,\n PARTITION p202007SUB01 VALUES LESS THAN (737975) ENGINE = InnoDB,\n PARTITION p202007SUB02 VALUES LESS THAN (737977) ENGINE = InnoDB,\n PARTITION p202007SUB03 VALUES LESS THAN (737979) ENGINE = InnoDB,\n PARTITION p202007SUB04 VALUES LESS THAN (737981) ENGINE = InnoDB,\n PARTITION p202007SUB05 VALUES LESS THAN (737983) ENGINE = InnoDB,\n PARTITION p202007SUB06 VALUES LESS THAN (737985) ENGINE = InnoDB,\n PARTITION p202007SUB07 VALUES LESS THAN (737987) ENGINE = InnoDB,\n PARTITION p202007SUB08 VALUES LESS THAN (737989) ENGINE = InnoDB,\n PARTITION p202007SUB09 VALUES LESS THAN (737991) ENGINE = InnoDB,\n PARTITION p202007SUB10 VALUES LESS THAN (737993) ENGINE = InnoDB,\n PARTITION p202007SUB11 VALUES LESS THAN (737995) ENGINE = InnoDB,\n PARTITION p202007SUB12 VALUES LESS THAN (737997) ENGINE = InnoDB,\n PARTITION p202007SUB13 VALUES LESS THAN (737999) ENGINE = InnoDB,\n PARTITION p202007SUB14 VALUES LESS THAN (738001) ENGINE = InnoDB,\n PARTITION p202008SUB00 VALUES LESS THAN (738004) ENGINE = InnoDB,\n PARTITION p202008SUB01 VALUES LESS THAN (738006) ENGINE = InnoDB,\n PARTITION p202008SUB02 VALUES LESS THAN (738008) ENGINE = InnoDB,\n PARTITION p202008SUB03 VALUES LESS THAN (738010) ENGINE = InnoDB,\n PARTITION p202008SUB04 VALUES LESS THAN (738012) ENGINE = InnoDB,\n PARTITION p202008SUB05 VALUES LESS THAN (738014) ENGINE = InnoDB,\n PARTITION p202008SUB06 VALUES LESS THAN (738016) ENGINE = InnoDB,\n PARTITION p202008SUB07 VALUES LESS THAN (738018) ENGINE = InnoDB,\n PARTITION p202008SUB08 VALUES LESS THAN (738020) ENGINE = InnoDB,\n PARTITION p202008SUB09 VALUES LESS THAN (738022) ENGINE = InnoDB,\n PARTITION p202008SUB10 VALUES LESS THAN (738024) ENGINE = InnoDB,\n PARTITION p202008SUB11 VALUES LESS THAN (738026) ENGINE = InnoDB,\n PARTITION p202008SUB12 VALUES LESS THAN (738028) ENGINE = InnoDB,\n PARTITION p202008SUB13 VALUES LESS THAN (738030) ENGINE = InnoDB,\n PARTITION p202008SUB14 VALUES LESS THAN (738032) ENGINE = InnoDB,\n PARTITION p202009SUB00 VALUES LESS THAN (738035) ENGINE = InnoDB,\n PARTITION p202009SUB01 VALUES LESS THAN (738037) ENGINE = InnoDB,\n PARTITION p202009SUB02 VALUES LESS THAN (738039) ENGINE = InnoDB,\n PARTITION p202009SUB03 VALUES LESS THAN (738041) ENGINE = InnoDB,\n PARTITION p202009SUB04 VALUES LESS THAN (738043) ENGINE = InnoDB,\n PARTITION p202009SUB05 VALUES LESS THAN (738045) ENGINE = InnoDB,\n PARTITION p202009SUB06 VALUES LESS THAN (738047) ENGINE = InnoDB,\n PARTITION p202009SUB07 VALUES LESS THAN (738049) ENGINE = InnoDB,\n PARTITION p202009SUB08 VALUES LESS THAN (738051) ENGINE = InnoDB,\n PARTITION p202009SUB09 VALUES LESS THAN (738053) ENGINE = InnoDB,\n PARTITION p202009SUB10 VALUES LESS THAN (738055) ENGINE = InnoDB,\n PARTITION p202009SUB11 VALUES LESS THAN (738057) ENGINE = InnoDB,\n PARTITION p202009SUB12 VALUES LESS THAN (738059) ENGINE = InnoDB,\n PARTITION p202009SUB13 VALUES LESS THAN (738061) ENGINE = InnoDB,\n PARTITION p202009SUB14 VALUES LESS THAN (738063) ENGINE = InnoDB,\n PARTITION p202010SUB00 VALUES LESS THAN (738065) ENGINE = InnoDB,\n PARTITION p202010SUB01 VALUES LESS THAN (738067) ENGINE = InnoDB,\n PARTITION p202010SUB02 VALUES LESS THAN (738069) ENGINE = InnoDB,\n PARTITION p202010SUB03 VALUES LESS THAN (738071) ENGINE = InnoDB,\n PARTITION p202010SUB04 VALUES LESS THAN (738073) ENGINE = InnoDB,\n PARTITION p202010SUB05 VALUES LESS THAN (738075) ENGINE = InnoDB,\n PARTITION p202010SUB06 VALUES LESS THAN (738077) ENGINE = InnoDB,\n PARTITION p202010SUB07 VALUES LESS THAN (738079) ENGINE = InnoDB,\n PARTITION p202010SUB08 VALUES LESS THAN (738081) ENGINE = InnoDB,\n PARTITION p202010SUB09 VALUES LESS THAN (738083) ENGINE = InnoDB,\n PARTITION p202010SUB10 VALUES LESS THAN (738085) ENGINE = InnoDB,\n PARTITION p202010SUB11 VALUES LESS THAN (738087) ENGINE = InnoDB,\n PARTITION p202010SUB12 VALUES LESS THAN (738089) ENGINE = InnoDB,\n PARTITION p202010SUB13 VALUES LESS THAN (738091) ENGINE = InnoDB,\n PARTITION p202010SUB14 VALUES LESS THAN (738093) ENGINE = InnoDB,\n PARTITION p202011SUB00 VALUES LESS THAN (738096) ENGINE = InnoDB,\n PARTITION p202011SUB01 VALUES LESS THAN (738098) ENGINE = InnoDB,\n PARTITION p202011SUB02 VALUES LESS THAN (738100) ENGINE = InnoDB,\n PARTITION p202011SUB03 VALUES LESS THAN (738102) ENGINE = InnoDB,\n PARTITION p202011SUB04 VALUES LESS THAN (738104) ENGINE = InnoDB,\n PARTITION p202011SUB05 VALUES LESS THAN (738106) ENGINE = InnoDB,\n PARTITION p202011SUB06 VALUES LESS THAN (738108) ENGINE = InnoDB,\n PARTITION p202011SUB07 VALUES LESS THAN (738110) ENGINE = InnoDB,\n PARTITION p202011SUB08 VALUES LESS THAN (738112) ENGINE = InnoDB,\n PARTITION p202011SUB09 VALUES LESS THAN (738114) ENGINE = InnoDB,\n PARTITION p202011SUB10 VALUES LESS THAN (738116) ENGINE = InnoDB,\n PARTITION p202011SUB11 VALUES LESS THAN (738118) ENGINE = InnoDB,\n PARTITION p202011SUB12 VALUES LESS THAN (738120) ENGINE = InnoDB,\n PARTITION p202011SUB13 VALUES LESS THAN (738122) ENGINE = InnoDB,\n PARTITION p202011SUB14 VALUES LESS THAN (738124) ENGINE = InnoDB,\n PARTITION p202012SUB00 VALUES LESS THAN (738126) ENGINE = InnoDB,\n PARTITION p202012SUB01 VALUES LESS THAN (738128) ENGINE = InnoDB,\n PARTITION p202012SUB02 VALUES LESS THAN (738130) ENGINE = InnoDB,\n PARTITION p202012SUB03 VALUES LESS THAN (738132) ENGINE = InnoDB,\n PARTITION p202012SUB04 VALUES LESS THAN (738134) ENGINE = InnoDB,\n PARTITION p202012SUB05 VALUES LESS THAN (738136) ENGINE = InnoDB,\n PARTITION p202012SUB06 VALUES LESS THAN (738138) ENGINE = InnoDB,\n PARTITION p202012SUB07 VALUES LESS THAN (738140) ENGINE = InnoDB,\n PARTITION p202012SUB08 VALUES LESS THAN (738142) ENGINE = InnoDB,\n PARTITION p202012SUB09 VALUES LESS THAN (738144) ENGINE = InnoDB,\n PARTITION p202012SUB10 VALUES LESS THAN (738146) ENGINE = InnoDB,\n PARTITION p202012SUB11 VALUES LESS THAN (738148) ENGINE = InnoDB,\n PARTITION p202012SUB12 VALUES LESS THAN (738150) ENGINE = InnoDB,\n PARTITION p202012SUB13 VALUES LESS THAN (738152) ENGINE = InnoDB,\n PARTITION p202012SUB14 VALUES LESS THAN (738154) ENGINE = InnoDB,\n PARTITION p202101SUB00 VALUES LESS THAN (738157) ENGINE = InnoDB,\n PARTITION p202101SUB01 VALUES LESS THAN (738159) ENGINE = InnoDB,\n PARTITION p202101SUB02 VALUES LESS THAN (738161) ENGINE = InnoDB,\n PARTITION p202101SUB03 VALUES LESS THAN (738163) ENGINE = InnoDB,\n PARTITION p202101SUB04 VALUES LESS THAN (738165) ENGINE = InnoDB,\n PARTITION p202101SUB05 VALUES LESS THAN (738167) ENGINE = InnoDB,\n PARTITION p202101SUB06 VALUES LESS THAN (738169) ENGINE = InnoDB,\n PARTITION p202101SUB07 VALUES LESS THAN (738171) ENGINE = InnoDB,\n PARTITION p202101SUB08 VALUES LESS THAN (738173) ENGINE = InnoDB,\n PARTITION p202101SUB09 VALUES LESS THAN (738175) ENGINE = InnoDB,\n PARTITION p202101SUB10 VALUES LESS THAN (738177) ENGINE = InnoDB,\n PARTITION p202101SUB11 VALUES LESS THAN (738179) ENGINE = InnoDB,\n PARTITION p202101SUB12 VALUES LESS THAN (738181) ENGINE = InnoDB,\n PARTITION p202101SUB13 VALUES LESS THAN (738183) ENGINE = InnoDB,\n PARTITION p202101SUB14 VALUES LESS THAN (738185) ENGINE = InnoDB,\n PARTITION p202102SUB00 VALUES LESS THAN (738188) ENGINE = InnoDB,\n PARTITION p202102SUB01 VALUES LESS THAN (738190) ENGINE = InnoDB,\n PARTITION p202102SUB02 VALUES LESS THAN (738192) ENGINE = InnoDB,\n PARTITION p202102SUB03 VALUES LESS THAN (738194) ENGINE = InnoDB,\n PARTITION p202102SUB04 VALUES LESS THAN (738196) ENGINE = InnoDB,\n PARTITION p202102SUB05 VALUES LESS THAN (738198) ENGINE = InnoDB,\n PARTITION p202102SUB06 VALUES LESS THAN (738200) ENGINE = InnoDB,\n PARTITION p202102SUB07 VALUES LESS THAN (738202) ENGINE = InnoDB,\n PARTITION p202102SUB08 VALUES LESS THAN (738204) ENGINE = InnoDB,\n PARTITION p202102SUB09 VALUES LESS THAN (738206) ENGINE = InnoDB,\n PARTITION p202102SUB10 VALUES LESS THAN (738208) ENGINE = InnoDB,\n PARTITION p202102SUB11 VALUES LESS THAN (738210) ENGINE = InnoDB,\n PARTITION p202102SUB12 VALUES LESS THAN (738212) ENGINE = InnoDB,\n PARTITION p202102SUB13 VALUES LESS THAN (738214) ENGINE = InnoDB,\n PARTITION p202103SUB00 VALUES LESS THAN (738216) ENGINE = InnoDB,\n PARTITION p202103SUB01 VALUES LESS THAN (738218) ENGINE = InnoDB,\n PARTITION p202103SUB02 VALUES LESS THAN (738220) ENGINE = InnoDB,\n PARTITION p202103SUB03 VALUES LESS THAN (738222) ENGINE = InnoDB,\n PARTITION p202103SUB04 VALUES LESS THAN (738224) ENGINE = InnoDB,\n PARTITION p202103SUB05 VALUES LESS THAN (738226) ENGINE = InnoDB,\n PARTITION p202103SUB06 VALUES LESS THAN (738228) ENGINE = InnoDB,\n PARTITION p202103SUB07 VALUES LESS THAN (738230) ENGINE = InnoDB,\n PARTITION p202103SUB08 VALUES LESS THAN (738232) ENGINE = InnoDB,\n PARTITION p202103SUB09 VALUES LESS THAN (738234) ENGINE = InnoDB,\n PARTITION p202103SUB10 VALUES LESS THAN (738236) ENGINE = InnoDB,\n PARTITION p202103SUB11 VALUES LESS THAN (738238) ENGINE = InnoDB,\n PARTITION p202103SUB12 VALUES LESS THAN (738240) ENGINE = InnoDB,\n PARTITION p202103SUB13 VALUES LESS THAN (738242) ENGINE = InnoDB,\n PARTITION p202103SUB14 VALUES LESS THAN (738244) ENGINE = InnoDB,\n PARTITION p202104SUB00 VALUES LESS THAN (738247) ENGINE = InnoDB,\n PARTITION p202104SUB01 VALUES LESS THAN (738249) ENGINE = InnoDB,\n PARTITION p202104SUB02 VALUES LESS THAN (738251) ENGINE = InnoDB,\n PARTITION p202104SUB03 VALUES LESS THAN (738253) ENGINE = InnoDB,\n PARTITION p202104SUB04 VALUES LESS THAN (738255) ENGINE = InnoDB,\n PARTITION p202104SUB05 VALUES LESS THAN (738257) ENGINE = InnoDB,\n PARTITION p202104SUB06 VALUES LESS THAN (738259) ENGINE = InnoDB,\n PARTITION p202104SUB07 VALUES LESS THAN (738261) ENGINE = InnoDB,\n PARTITION p202104SUB08 VALUES LESS THAN (738263) ENGINE = InnoDB,\n PARTITION p202104SUB09 VALUES LESS THAN (738265) ENGINE = InnoDB,\n PARTITION p202104SUB10 VALUES LESS THAN (738267) ENGINE = InnoDB,\n PARTITION p202104SUB11 VALUES LESS THAN (738269) ENGINE = InnoDB,\n PARTITION p202104SUB12 VALUES LESS THAN (738271) ENGINE = InnoDB,\n PARTITION p202104SUB13 VALUES LESS THAN (738273) ENGINE = InnoDB,\n PARTITION p202104SUB14 VALUES LESS THAN (738275) ENGINE = InnoDB,\n PARTITION p202105SUB00 VALUES LESS THAN (738277) ENGINE = InnoDB,\n PARTITION p202105SUB01 VALUES LESS THAN (738279) ENGINE = InnoDB,\n PARTITION p202105SUB02 VALUES LESS THAN (738281) ENGINE = InnoDB,\n PARTITION p202105SUB03 VALUES LESS THAN (738283) ENGINE = InnoDB,\n PARTITION p202105SUB04 VALUES LESS THAN (738285) ENGINE = InnoDB,\n PARTITION p202105SUB05 VALUES LESS THAN (738287) ENGINE = InnoDB,\n PARTITION p202105SUB06 VALUES LESS THAN (738289) ENGINE = InnoDB,\n PARTITION p202105SUB07 VALUES LESS THAN (738291) ENGINE = InnoDB,\n PARTITION p202105SUB08 VALUES LESS THAN (738293) ENGINE = InnoDB,\n PARTITION p202105SUB09 VALUES LESS THAN (738295) ENGINE = InnoDB,\n PARTITION p202105SUB10 VALUES LESS THAN (738297) ENGINE = InnoDB,\n PARTITION p202105SUB11 VALUES LESS THAN (738299) ENGINE = InnoDB,\n PARTITION p202105SUB12 VALUES LESS THAN (738301) ENGINE = InnoDB,\n PARTITION p202105SUB13 VALUES LESS THAN (738303) ENGINE = InnoDB,\n PARTITION p202105SUB14 VALUES LESS THAN (738305) ENGINE = InnoDB,\n PARTITION p202106SUB00 VALUES LESS THAN (738308) ENGINE = InnoDB,\n PARTITION p202106SUB01 VALUES LESS THAN (738310) ENGINE = InnoDB,\n PARTITION p202106SUB02 VALUES LESS THAN (738312) ENGINE = InnoDB,\n PARTITION p202106SUB03 VALUES LESS THAN (738314) ENGINE = InnoDB,\n PARTITION p202106SUB04 VALUES LESS THAN (738316) ENGINE = InnoDB,\n PARTITION p202106SUB05 VALUES LESS THAN (738318) ENGINE = InnoDB,\n PARTITION p202106SUB06 VALUES LESS THAN (738320) ENGINE = InnoDB,\n PARTITION p202106SUB07 VALUES LESS THAN (738322) ENGINE = InnoDB,\n PARTITION p202106SUB08 VALUES LESS THAN (738324) ENGINE = InnoDB,\n PARTITION p202106SUB09 VALUES LESS THAN (738326) ENGINE = InnoDB,\n PARTITION p202106SUB10 VALUES LESS THAN (738328) ENGINE = InnoDB,\n PARTITION p202106SUB11 VALUES LESS THAN (738330) ENGINE = InnoDB,\n PARTITION p202106SUB12 VALUES LESS THAN (738332) ENGINE = InnoDB,\n PARTITION p202106SUB13 VALUES LESS THAN (738334) ENGINE = InnoDB,\n PARTITION p202106SUB14 VALUES LESS THAN (738336) ENGINE = InnoDB,\n PARTITION p202107SUB00 VALUES LESS THAN (738338) ENGINE = InnoDB,\n PARTITION p202107SUB01 VALUES LESS THAN (738340) ENGINE = InnoDB,\n PARTITION p202107SUB02 VALUES LESS THAN (738342) ENGINE = InnoDB,\n PARTITION p202107SUB03 VALUES LESS THAN (738344) ENGINE = InnoDB,\n PARTITION p202107SUB04 VALUES LESS THAN (738346) ENGINE = InnoDB,\n PARTITION p202107SUB05 VALUES LESS THAN (738348) ENGINE = InnoDB,\n PARTITION p202107SUB06 VALUES LESS THAN (738350) ENGINE = InnoDB,\n PARTITION p202107SUB07 VALUES LESS THAN (738352) ENGINE = InnoDB,\n PARTITION p202107SUB08 VALUES LESS THAN (738354) ENGINE = InnoDB,\n PARTITION p202107SUB09 VALUES LESS THAN (738356) ENGINE = InnoDB,\n PARTITION p202107SUB10 VALUES LESS THAN (738358) ENGINE = InnoDB,\n PARTITION p202107SUB11 VALUES LESS THAN (738360) ENGINE = InnoDB,\n PARTITION p202107SUB12 VALUES LESS THAN (738362) ENGINE = InnoDB,\n PARTITION p202107SUB13 VALUES LESS THAN (738364) ENGINE = InnoDB,\n PARTITION p202107SUB14 VALUES LESS THAN (738366) ENGINE = InnoDB,\n PARTITION p202108SUB00 VALUES LESS THAN (738369) ENGINE = InnoDB,\n PARTITION p202108SUB01 VALUES LESS THAN (738371) ENGINE = InnoDB,\n PARTITION p202108SUB02 VALUES LESS THAN (738373) ENGINE = InnoDB,\n PARTITION p202108SUB03 VALUES LESS THAN (738375) ENGINE = InnoDB,\n PARTITION p202108SUB04 VALUES LESS THAN (738377) ENGINE = InnoDB,\n PARTITION p202108SUB05 VALUES LESS THAN (738379) ENGINE = InnoDB,\n PARTITION p202108SUB06 VALUES LESS THAN (738381) ENGINE = InnoDB,\n PARTITION p202108SUB07 VALUES LESS THAN (738383) ENGINE = InnoDB,\n PARTITION p202108SUB08 VALUES LESS THAN (738385) ENGINE = InnoDB,\n PARTITION p202108SUB09 VALUES LESS THAN (738387) ENGINE = InnoDB,\n PARTITION p202108SUB10 VALUES LESS THAN (738389) ENGINE = InnoDB,\n PARTITION p202108SUB11 VALUES LESS THAN (738391) ENGINE = InnoDB,\n PARTITION p202108SUB12 VALUES LESS THAN (738393) ENGINE = InnoDB,\n PARTITION p202108SUB13 VALUES LESS THAN (738395) ENGINE = InnoDB,\n PARTITION p202108SUB14 VALUES LESS THAN (738397) ENGINE = InnoDB,\n PARTITION p202109SUB00 VALUES LESS THAN (738400) ENGINE = InnoDB,\n PARTITION p202109SUB01 VALUES LESS THAN (738402) ENGINE = InnoDB,\n PARTITION p202109SUB02 VALUES LESS THAN (738404) ENGINE = InnoDB,\n PARTITION p202109SUB03 VALUES LESS THAN (738406) ENGINE = InnoDB,\n PARTITION p202109SUB04 VALUES LESS THAN (738408) ENGINE = InnoDB,\n PARTITION p202109SUB05 VALUES LESS THAN (738410) ENGINE = InnoDB,\n PARTITION p202109SUB06 VALUES LESS THAN (738412) ENGINE = InnoDB,\n PARTITION p202109SUB07 VALUES LESS THAN (738414) ENGINE = InnoDB,\n PARTITION p202109SUB08 VALUES LESS THAN (738416) ENGINE = InnoDB,\n PARTITION p202109SUB09 VALUES LESS THAN (738418) ENGINE = InnoDB,\n PARTITION p202109SUB10 VALUES LESS THAN (738420) ENGINE = InnoDB,\n PARTITION p202109SUB11 VALUES LESS THAN (738422) ENGINE = InnoDB,\n PARTITION p202109SUB12 VALUES LESS THAN (738424) ENGINE = InnoDB,\n PARTITION p202109SUB13 VALUES LESS THAN (738426) ENGINE = InnoDB,\n PARTITION p202109SUB14 VALUES LESS THAN (738428) ENGINE = InnoDB,\n PARTITION p202110SUB00 VALUES LESS THAN (738430) ENGINE = InnoDB,\n PARTITION p202110SUB01 VALUES LESS THAN (738432) ENGINE = InnoDB,\n PARTITION p202110SUB02 VALUES LESS THAN (738434) ENGINE = InnoDB,\n PARTITION p202110SUB03 VALUES LESS THAN (738436) ENGINE = InnoDB,\n PARTITION p202110SUB04 VALUES LESS THAN (738438) ENGINE = InnoDB,\n PARTITION p202110SUB05 VALUES LESS THAN (738440) ENGINE = InnoDB,\n PARTITION p202110SUB06 VALUES LESS THAN (738442) ENGINE = InnoDB,\n PARTITION p202110SUB07 VALUES LESS THAN (738444) ENGINE = InnoDB,\n PARTITION p202110SUB08 VALUES LESS THAN (738446) ENGINE = InnoDB,\n PARTITION p202110SUB09 VALUES LESS THAN (738448) ENGINE = InnoDB,\n PARTITION p202110SUB10 VALUES LESS THAN (738450) ENGINE = InnoDB,\n PARTITION p202110SUB11 VALUES LESS THAN (738452) ENGINE = InnoDB,\n PARTITION p202110SUB12 VALUES LESS THAN (738454) ENGINE = InnoDB,\n PARTITION p202110SUB13 VALUES LESS THAN (738456) ENGINE = InnoDB,\n PARTITION p202110SUB14 VALUES LESS THAN (738458) ENGINE = InnoDB,\n PARTITION p202111SUB00 VALUES LESS THAN (738461) ENGINE = InnoDB,\n PARTITION p202111SUB01 VALUES LESS THAN (738463) ENGINE = InnoDB,\n PARTITION p202111SUB02 VALUES LESS THAN (738465) ENGINE = InnoDB,\n PARTITION p202111SUB03 VALUES LESS THAN (738467) ENGINE = InnoDB,\n PARTITION p202111SUB04 VALUES LESS THAN (738469) ENGINE = InnoDB,\n PARTITION p202111SUB05 VALUES LESS THAN (738471) ENGINE = InnoDB,\n PARTITION p202111SUB06 VALUES LESS THAN (738473) ENGINE = InnoDB,\n PARTITION p202111SUB07 VALUES LESS THAN (738475) ENGINE = InnoDB,\n PARTITION p202111SUB08 VALUES LESS THAN (738477) ENGINE = InnoDB,\n PARTITION p202111SUB09 VALUES LESS THAN (738479) ENGINE = InnoDB,\n PARTITION p202111SUB10 VALUES LESS THAN (738481) ENGINE = InnoDB,\n PARTITION p202111SUB11 VALUES LESS THAN (738483) ENGINE = InnoDB,\n PARTITION p202111SUB12 VALUES LESS THAN (738485) ENGINE = InnoDB,\n PARTITION p202111SUB13 VALUES LESS THAN (738487) ENGINE = InnoDB,\n PARTITION p202111SUB14 VALUES LESS THAN (738489) ENGINE = InnoDB,\n PARTITION p202112SUB00 VALUES LESS THAN (738491) ENGINE = InnoDB,\n PARTITION p202112SUB01 VALUES LESS THAN (738493) ENGINE = InnoDB,\n PARTITION p202112SUB02 VALUES LESS THAN (738495) ENGINE = InnoDB,\n PARTITION p202112SUB03 VALUES LESS THAN (738497) ENGINE = InnoDB,\n PARTITION p202112SUB04 VALUES LESS THAN (738499) ENGINE = InnoDB,\n PARTITION p202112SUB05 VALUES LESS THAN (738501) ENGINE = InnoDB,\n PARTITION p202112SUB06 VALUES LESS THAN (738503) ENGINE = InnoDB,\n PARTITION p202112SUB07 VALUES LESS THAN (738505) ENGINE = InnoDB,\n PARTITION p202112SUB08 VALUES LESS THAN (738507) ENGINE = InnoDB,\n PARTITION p202112SUB09 VALUES LESS THAN (738509) ENGINE = InnoDB,\n PARTITION p202112SUB10 VALUES LESS THAN (738511) ENGINE = InnoDB,\n PARTITION p202112SUB11 VALUES LESS THAN (738513) ENGINE = InnoDB,\n PARTITION p202112SUB12 VALUES LESS THAN (738515) ENGINE = InnoDB,\n PARTITION p202112SUB13 VALUES LESS THAN (738517) ENGINE = InnoDB,\n PARTITION p202112SUB14 VALUES LESS THAN (738519) ENGINE = InnoDB,\n PARTITION p202201SUB00 VALUES LESS THAN (738522) ENGINE = InnoDB,\n PARTITION p202201SUB01 VALUES LESS THAN (738524) ENGINE = InnoDB,\n PARTITION p202201SUB02 VALUES LESS THAN (738526) ENGINE = InnoDB,\n PARTITION p202201SUB03 VALUES LESS THAN (738528) ENGINE = InnoDB,\n PARTITION p202201SUB04 VALUES LESS THAN (738530) ENGINE = InnoDB,\n PARTITION p202201SUB05 VALUES LESS THAN (738532) ENGINE = InnoDB,\n PARTITION p202201SUB06 VALUES LESS THAN (738534) ENGINE = InnoDB,\n PARTITION p202201SUB07 VALUES LESS THAN (738536) ENGINE = InnoDB,\n PARTITION p202201SUB08 VALUES LESS THAN (738538) ENGINE = InnoDB,\n PARTITION p202201SUB09 VALUES LESS THAN (738540) ENGINE = InnoDB,\n PARTITION p202201SUB10 VALUES LESS THAN (738542) ENGINE = InnoDB,\n PARTITION p202201SUB11 VALUES LESS THAN (738544) ENGINE = InnoDB,\n PARTITION p202201SUB12 VALUES LESS THAN (738546) ENGINE = InnoDB,\n PARTITION p202201SUB13 VALUES LESS THAN (738548) ENGINE = InnoDB,\n PARTITION p202201SUB14 VALUES LESS THAN (738550) ENGINE = InnoDB,\n PARTITION p202202SUB00 VALUES LESS THAN (738553) ENGINE = InnoDB,\n PARTITION p202202SUB01 VALUES LESS THAN (738555) ENGINE = InnoDB,\n PARTITION p202202SUB02 VALUES LESS THAN (738557) ENGINE = InnoDB,\n PARTITION p202202SUB03 VALUES LESS THAN (738559) ENGINE = InnoDB,\n PARTITION p202202SUB04 VALUES LESS THAN (738561) ENGINE = InnoDB,\n PARTITION p202202SUB05 VALUES LESS THAN (738563) ENGINE = InnoDB,\n PARTITION p202202SUB06 VALUES LESS THAN (738565) ENGINE = InnoDB,\n PARTITION p202202SUB07 VALUES LESS THAN (738567) ENGINE = InnoDB,\n PARTITION p202202SUB08 VALUES LESS THAN (738569) ENGINE = InnoDB,\n PARTITION p202202SUB09 VALUES LESS THAN (738571) ENGINE = InnoDB,\n PARTITION p202202SUB10 VALUES LESS THAN (738573) ENGINE = InnoDB,\n PARTITION p202202SUB11 VALUES LESS THAN (738575) ENGINE = InnoDB,\n PARTITION p202202SUB12 VALUES LESS THAN (738577) ENGINE = InnoDB,\n PARTITION p202202SUB13 VALUES LESS THAN (738579) ENGINE = InnoDB,\n PARTITION p202203SUB00 VALUES LESS THAN (738581) ENGINE = InnoDB,\n PARTITION p202203SUB01 VALUES LESS THAN (738583) ENGINE = InnoDB,\n PARTITION p202203SUB02 VALUES LESS THAN (738585) ENGINE = InnoDB,\n PARTITION p202203SUB03 VALUES LESS THAN (738587) ENGINE = InnoDB,\n PARTITION p202203SUB04 VALUES LESS THAN (738589) ENGINE = InnoDB,\n PARTITION p202203SUB05 VALUES LESS THAN (738591) ENGINE = InnoDB,\n PARTITION p202203SUB06 VALUES LESS THAN (738593) ENGINE = InnoDB,\n PARTITION p202203SUB07 VALUES LESS THAN (738595) ENGINE = InnoDB,\n PARTITION p202203SUB08 VALUES LESS THAN (738597) ENGINE = InnoDB,\n PARTITION p202203SUB09 VALUES LESS THAN (738599) ENGINE = InnoDB,\n PARTITION p202203SUB10 VALUES LESS THAN (738601) ENGINE = InnoDB,\n PARTITION p202203SUB11 VALUES LESS THAN (738603) ENGINE = InnoDB,\n PARTITION p202203SUB12 VALUES LESS THAN (738605) ENGINE = InnoDB,\n PARTITION p202203SUB13 VALUES LESS THAN (738607) ENGINE = InnoDB,\n PARTITION p202203SUB14 VALUES LESS THAN (738609) ENGINE = InnoDB,\n PARTITION p202204SUB00 VALUES LESS THAN (738612) ENGINE = InnoDB,\n PARTITION p202204SUB01 VALUES LESS THAN (738614) ENGINE = InnoDB,\n PARTITION p202204SUB02 VALUES LESS THAN (738616) ENGINE = InnoDB,\n PARTITION p202204SUB03 VALUES LESS THAN (738618) ENGINE = InnoDB,\n PARTITION p202204SUB04 VALUES LESS THAN (738620) ENGINE = InnoDB,\n PARTITION p202204SUB05 VALUES LESS THAN (738622) ENGINE = InnoDB,\n PARTITION p202204SUB06 VALUES LESS THAN (738624) ENGINE = InnoDB,\n PARTITION p202204SUB07 VALUES LESS THAN (738626) ENGINE = InnoDB,\n PARTITION p202204SUB08 VALUES LESS THAN (738628) ENGINE = InnoDB,\n PARTITION p202204SUB09 VALUES LESS THAN (738630) ENGINE = InnoDB,\n PARTITION p202204SUB10 VALUES LESS THAN (738632) ENGINE = InnoDB,\n PARTITION p202204SUB11 VALUES LESS THAN (738634) ENGINE = InnoDB,\n PARTITION p202204SUB12 VALUES LESS THAN (738636) ENGINE = InnoDB,\n PARTITION p202204SUB13 VALUES LESS THAN (738638) ENGINE = InnoDB,\n PARTITION p202204SUB14 VALUES LESS THAN (738640) ENGINE = InnoDB,\n PARTITION p202205SUB00 VALUES LESS THAN (738642) ENGINE = InnoDB,\n PARTITION p202205SUB01 VALUES LESS THAN (738644) ENGINE = InnoDB,\n PARTITION p202205SUB02 VALUES LESS THAN (738646) ENGINE = InnoDB,\n PARTITION p202205SUB03 VALUES LESS THAN (738648) ENGINE = InnoDB,\n PARTITION p202205SUB04 VALUES LESS THAN (738650) ENGINE = InnoDB,\n PARTITION p202205SUB05 VALUES LESS THAN (738652) ENGINE = InnoDB,\n PARTITION p202205SUB06 VALUES LESS THAN (738654) ENGINE = InnoDB,\n PARTITION p202205SUB07 VALUES LESS THAN (738656) ENGINE = InnoDB,\n PARTITION p202205SUB08 VALUES LESS THAN (738658) ENGINE = InnoDB,\n PARTITION p202205SUB09 VALUES LESS THAN (738660) ENGINE = InnoDB,\n PARTITION p202205SUB10 VALUES LESS THAN (738662) ENGINE = InnoDB,\n PARTITION p202205SUB11 VALUES LESS THAN (738664) ENGINE = InnoDB,\n PARTITION p202205SUB12 VALUES LESS THAN (738666) ENGINE = InnoDB,\n PARTITION p202205SUB13 VALUES LESS THAN (738668) ENGINE = InnoDB,\n PARTITION p202205SUB14 VALUES LESS THAN (738670) ENGINE = InnoDB,\n PARTITION p202206SUB00 VALUES LESS THAN (738673) ENGINE = InnoDB,\n PARTITION p202206SUB01 VALUES LESS THAN (738675) ENGINE = InnoDB,\n PARTITION p202206SUB02 VALUES LESS THAN (738677) ENGINE = InnoDB,\n PARTITION p202206SUB03 VALUES LESS THAN (738679) ENGINE = InnoDB,\n PARTITION p202206SUB04 VALUES LESS THAN (738681) ENGINE = InnoDB,\n PARTITION p202206SUB05 VALUES LESS THAN (738683) ENGINE = InnoDB,\n PARTITION p202206SUB06 VALUES LESS THAN (738685) ENGINE = InnoDB,\n PARTITION p202206SUB07 VALUES LESS THAN (738687) ENGINE = InnoDB,\n PARTITION p202206SUB08 VALUES LESS THAN (738689) ENGINE = InnoDB,\n PARTITION p202206SUB09 VALUES LESS THAN (738691) ENGINE = InnoDB,\n PARTITION p202206SUB10 VALUES LESS THAN (738693) ENGINE = InnoDB,\n PARTITION p202206SUB11 VALUES LESS THAN (738695) ENGINE = InnoDB,\n PARTITION p202206SUB12 VALUES LESS THAN (738697) ENGINE = InnoDB,\n PARTITION p202206SUB13 VALUES LESS THAN (738699) ENGINE = InnoDB,\n PARTITION p202206SUB14 VALUES LESS THAN (738701) ENGINE = InnoDB,\n PARTITION p202207SUB00 VALUES LESS THAN (738703) ENGINE = InnoDB,\n PARTITION p202207SUB01 VALUES LESS THAN (738705) ENGINE = InnoDB,\n PARTITION p202207SUB02 VALUES LESS THAN (738707) ENGINE = InnoDB,\n PARTITION p202207SUB03 VALUES LESS THAN (738709) ENGINE = InnoDB,\n PARTITION p202207SUB04 VALUES LESS THAN (738711) ENGINE = InnoDB,\n PARTITION p202207SUB05 VALUES LESS THAN (738713) ENGINE = InnoDB,\n PARTITION p202207SUB06 VALUES LESS THAN (738715) ENGINE = InnoDB,\n PARTITION p202207SUB07 VALUES LESS THAN (738717) ENGINE = InnoDB,\n PARTITION p202207SUB08 VALUES LESS THAN (738719) ENGINE = InnoDB,\n PARTITION p202207SUB09 VALUES LESS THAN (738721) ENGINE = InnoDB,\n PARTITION p202207SUB10 VALUES LESS THAN (738723) ENGINE = InnoDB,\n PARTITION p202207SUB11 VALUES LESS THAN (738725) ENGINE = InnoDB,\n PARTITION p202207SUB12 VALUES LESS THAN (738727) ENGINE = InnoDB,\n PARTITION p202207SUB13 VALUES LESS THAN (738729) ENGINE = InnoDB,\n PARTITION p202207SUB14 VALUES LESS THAN (738731) ENGINE = InnoDB,\n PARTITION p202208SUB00 VALUES LESS THAN (738734) ENGINE = InnoDB,\n PARTITION p202208SUB01 VALUES LESS THAN (738736) ENGINE = InnoDB,\n PARTITION p202208SUB02 VALUES LESS THAN (738738) ENGINE = InnoDB,\n PARTITION p202208SUB03 VALUES LESS THAN (738740) ENGINE = InnoDB,\n PARTITION p202208SUB04 VALUES LESS THAN (738742) ENGINE = InnoDB,\n PARTITION p202208SUB05 VALUES LESS THAN (738744) ENGINE = InnoDB,\n PARTITION p202208SUB06 VALUES LESS THAN (738746) ENGINE = InnoDB,\n PARTITION p202208SUB07 VALUES LESS THAN (738748) ENGINE = InnoDB,\n PARTITION p202208SUB08 VALUES LESS THAN (738750) ENGINE = InnoDB,\n PARTITION p202208SUB09 VALUES LESS THAN (738752) ENGINE = InnoDB,\n PARTITION p202208SUB10 VALUES LESS THAN (738754) ENGINE = InnoDB,\n PARTITION p202208SUB11 VALUES LESS THAN (738756) ENGINE = InnoDB,\n PARTITION p202208SUB12 VALUES LESS THAN (738758) ENGINE = InnoDB,\n PARTITION p202208SUB13 VALUES LESS THAN (738760) ENGINE = InnoDB,\n PARTITION p202208SUB14 VALUES LESS THAN (738762) ENGINE = InnoDB,\n PARTITION p202209SUB00 VALUES LESS THAN (738765) ENGINE = InnoDB,\n PARTITION p202209SUB01 VALUES LESS THAN (738767) ENGINE = InnoDB,\n PARTITION p202209SUB02 VALUES LESS THAN (738769) ENGINE = InnoDB,\n PARTITION p202209SUB03 VALUES LESS THAN (738771) ENGINE = InnoDB,\n PARTITION p202209SUB04 VALUES LESS THAN (738773) ENGINE = InnoDB,\n PARTITION p202209SUB05 VALUES LESS THAN (738775) ENGINE = InnoDB,\n PARTITION p202209SUB06 VALUES LESS THAN (738777) ENGINE = InnoDB,\n PARTITION p202209SUB07 VALUES LESS THAN (738779) ENGINE = InnoDB,\n PARTITION p202209SUB08 VALUES LESS THAN (738781) ENGINE = InnoDB,\n PARTITION p202209SUB09 VALUES LESS THAN (738783) ENGINE = InnoDB,\n PARTITION p202209SUB10 VALUES LESS THAN (738785) ENGINE = InnoDB,\n PARTITION p202209SUB11 VALUES LESS THAN (738787) ENGINE = InnoDB,\n PARTITION p202209SUB12 VALUES LESS THAN (738789) ENGINE = InnoDB,\n PARTITION p202209SUB13 VALUES LESS THAN (738791) ENGINE = InnoDB,\n PARTITION p202209SUB14 VALUES LESS THAN (738793) ENGINE = InnoDB,\n PARTITION p202210SUB00 VALUES LESS THAN (738795) ENGINE = InnoDB,\n PARTITION p202210SUB01 VALUES LESS THAN (738797) ENGINE = InnoDB,\n PARTITION p202210SUB02 VALUES LESS THAN (738799) ENGINE = InnoDB,\n PARTITION p202210SUB03 VALUES LESS THAN (738801) ENGINE = InnoDB,\n PARTITION p202210SUB04 VALUES LESS THAN (738803) ENGINE = InnoDB,\n PARTITION p202210SUB05 VALUES LESS THAN (738805) ENGINE = InnoDB,\n PARTITION p202210SUB06 VALUES LESS THAN (738807) ENGINE = InnoDB,\n PARTITION p202210SUB07 VALUES LESS THAN (738809) ENGINE = InnoDB,\n PARTITION p202210SUB08 VALUES LESS THAN (738811) ENGINE = InnoDB,\n PARTITION p202210SUB09 VALUES LESS THAN (738813) ENGINE = InnoDB,\n PARTITION p202210SUB10 VALUES LESS THAN (738815) ENGINE = InnoDB,\n PARTITION p202210SUB11 VALUES LESS THAN (738817) ENGINE = InnoDB,\n PARTITION p202210SUB12 VALUES LESS THAN (738819) ENGINE = InnoDB,\n PARTITION p202210SUB13 VALUES LESS THAN (738821) ENGINE = InnoDB,\n PARTITION p202210SUB14 VALUES LESS THAN (738823) ENGINE = InnoDB,\n PARTITION p202211SUB00 VALUES LESS THAN (738826) ENGINE = InnoDB,\n PARTITION p202211SUB01 VALUES LESS THAN (738828) ENGINE = InnoDB,\n PARTITION p202211SUB02 VALUES LESS THAN (738830) ENGINE = InnoDB,\n PARTITION p202211SUB03 VALUES LESS THAN (738832) ENGINE = InnoDB,\n PARTITION p202211SUB04 VALUES LESS THAN (738834) ENGINE = InnoDB,\n PARTITION p202211SUB05 VALUES LESS THAN (738836) ENGINE = InnoDB,\n PARTITION p202211SUB06 VALUES LESS THAN (738838) ENGINE = InnoDB,\n PARTITION p202211SUB07 VALUES LESS THAN (738840) ENGINE = InnoDB,\n PARTITION p202211SUB08 VALUES LESS THAN (738842) ENGINE = InnoDB,\n PARTITION p202211SUB09 VALUES LESS THAN (738844) ENGINE = InnoDB,\n PARTITION p202211SUB10 VALUES LESS THAN (738846) ENGINE = InnoDB,\n PARTITION p202211SUB11 VALUES LESS THAN (738848) ENGINE = InnoDB,\n PARTITION p202211SUB12 VALUES LESS THAN (738850) ENGINE = InnoDB,\n PARTITION p202211SUB13 VALUES LESS THAN (738852) ENGINE = InnoDB,\n PARTITION p202211SUB14 VALUES LESS THAN (738854) ENGINE = InnoDB,\n PARTITION p202212SUB00 VALUES LESS THAN (738856) ENGINE = InnoDB,\n PARTITION p202212SUB01 VALUES LESS THAN (738858) ENGINE = InnoDB,\n PARTITION p202212SUB02 VALUES LESS THAN (738860) ENGINE = InnoDB,\n PARTITION p202212SUB03 VALUES LESS THAN (738862) ENGINE = InnoDB,\n PARTITION p202212SUB04 VALUES LESS THAN (738864) ENGINE = InnoDB,\n PARTITION p202212SUB05 VALUES LESS THAN (738866) ENGINE = InnoDB,\n PARTITION p202212SUB06 VALUES LESS THAN (738868) ENGINE = InnoDB,\n PARTITION p202212SUB07 VALUES LESS THAN (738870) ENGINE = InnoDB,\n PARTITION p202212SUB08 VALUES LESS THAN (738872) ENGINE = InnoDB,\n PARTITION p202212SUB09 VALUES LESS THAN (738874) ENGINE = InnoDB,\n PARTITION p202212SUB10 VALUES LESS THAN (738876) ENGINE = InnoDB,\n PARTITION p202212SUB11 VALUES LESS THAN (738878) ENGINE = InnoDB,\n PARTITION p202212SUB12 VALUES LESS THAN (738880) ENGINE = InnoDB,\n PARTITION p202212SUB13 VALUES LESS THAN (738882) ENGINE = InnoDB,\n PARTITION p202212SUB14 VALUES LESS THAN (738884) ENGINE = InnoDB) */", force: :cascade do |t|
    t.string "id", default: "", null: false, collation: "utf8_general_ci"
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "subid_1", collation: "utf8_general_ci"
    t.string "subid_2", collation: "utf8_general_ci"
    t.string "subid_3", collation: "utf8_general_ci"
    t.integer "language_id"
    t.string "http_user_agent", collation: "utf8_general_ci"
    t.string "http_referer", collation: "utf8_general_ci"
    t.string "ip_address", collation: "utf8_general_ci"
    t.integer "clicks"
    t.integer "conversions"
    t.datetime "recorded_at", default: "1970-01-01 00:00:00", null: false
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500, collation: "utf8_general_ci"
    t.string "status", collation: "utf8_general_ci"
    t.integer "image_creative_id"
    t.datetime "converted_at", default: "1970-01-01 00:00:00", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "vtm_host", collation: "utf8_general_ci"
    t.string "vtm_page", collation: "utf8_general_ci"
    t.string "vtm_channel", collation: "utf8_general_ci"
    t.integer "mkt_site_id"
    t.integer "hits"
    t.integer "mkt_url_id"
    t.string "vtm_campaign", collation: "utf8_general_ci"
    t.string "ip_country", collation: "utf8_general_ci"
    t.string "approval", collation: "utf8_general_ci"
    t.integer "order_id"
    t.string "step_name", collation: "utf8_general_ci"
    t.string "step_label", collation: "utf8_general_ci"
    t.string "true_conv_type", collation: "utf8_general_ci"
    t.string "affiliate_conv_type", collation: "utf8_general_ci"
    t.integer "lead_id"
    t.string "s1", collation: "utf8_general_ci"
    t.string "s2", collation: "utf8_general_ci"
    t.string "s3", collation: "utf8_general_ci"
    t.string "s4", collation: "utf8_general_ci"
    t.boolean "is_bot"
    t.integer "text_creative_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.string "keyword", collation: "utf8_general_ci"
    t.integer "share_creative_id"
    t.datetime "captured_at"
    t.string "isp", collation: "utf8_general_ci"
    t.string "browser", collation: "utf8_general_ci"
    t.string "browser_version", collation: "utf8_general_ci"
    t.string "device_type", collation: "utf8_general_ci"
    t.string "device_brand", collation: "utf8_general_ci"
    t.string "device_model", collation: "utf8_general_ci"
    t.string "aff_uniq_id", collation: "utf8_general_ci"
    t.string "ios_uniq", collation: "utf8_general_ci"
    t.string "android_uniq", collation: "utf8_general_ci"
    t.string "subid_4", collation: "utf8_general_ci"
    t.string "subid_5", collation: "utf8_general_ci"
    t.string "order_number", collation: "utf8_general_ci"
    t.string "gaid", collation: "utf8_general_ci"
    t.integer "email_creative_id"
    t.decimal "qscore", precision: 10, scale: 2
    t.string "ad_slot_id", collation: "utf8_general_ci"
    t.integer "impression"
    t.datetime "published_at"
    t.json "forex"
    t.string "original_currency", limit: 3
    t.string "adv_uniq_id"
    t.decimal "order_total", precision: 20, scale: 2
    t.index ["adv_uniq_id"], name: "index_affiliate_stat_converted_ats_on_adv_uniq_id"
    t.index ["aff_uniq_id"], name: "index_affiliate_stat_converted_ats_on_aff_uniq_id"
    t.index ["affiliate_id"], name: "index_affiliate_stat_converted_ats_on_affiliate_id"
    t.index ["id"], name: "index_affiliate_stat_converted_ats_on_id"
    t.index ["ip_address"], name: "index_affiliate_stat_converted_ats_on_ip_address"
    t.index ["network_id"], name: "index_affiliate_stat_converted_ats_on_network_id"
    t.index ["offer_id"], name: "index_affiliate_stat_converted_ats_on_offer_id"
    t.index ["order_id"], name: "index_affiliate_stat_converted_ats_on_order_id"
    t.index ["order_number"], name: "index_affiliate_stat_converted_ats_on_order_number"
    t.index ["status"], name: "index_affiliate_stat_converted_ats_on_status"
    t.index ["subid_1"], name: "index_affiliate_stat_converted_ats_on_subid_1"
    t.index ["subid_2"], name: "index_affiliate_stat_converted_ats_on_subid_2"
    t.index ["subid_3"], name: "index_affiliate_stat_converted_ats_on_subid_3"
    t.index ["subid_4"], name: "index_affiliate_stat_converted_ats_on_subid_4"
    t.index ["subid_5"], name: "index_affiliate_stat_converted_ats_on_subid_5"
    t.index ["updated_at"], name: "index_affiliate_stat_converted_ats_on_updated_at"
  end

  create_table "affiliate_stat_published_ats", primary_key: ["published_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", options: "ENGINE=InnoDB\n/*!50100 PARTITION BY RANGE ( TO_DAYS(published_at))\n(PARTITION p201801SUB00 VALUES LESS THAN (737061) ENGINE = InnoDB,\n PARTITION p201801SUB01 VALUES LESS THAN (737063) ENGINE = InnoDB,\n PARTITION p201801SUB02 VALUES LESS THAN (737065) ENGINE = InnoDB,\n PARTITION p201801SUB03 VALUES LESS THAN (737067) ENGINE = InnoDB,\n PARTITION p201801SUB04 VALUES LESS THAN (737069) ENGINE = InnoDB,\n PARTITION p201801SUB05 VALUES LESS THAN (737071) ENGINE = InnoDB,\n PARTITION p201801SUB06 VALUES LESS THAN (737073) ENGINE = InnoDB,\n PARTITION p201801SUB07 VALUES LESS THAN (737075) ENGINE = InnoDB,\n PARTITION p201801SUB08 VALUES LESS THAN (737077) ENGINE = InnoDB,\n PARTITION p201801SUB09 VALUES LESS THAN (737079) ENGINE = InnoDB,\n PARTITION p201801SUB10 VALUES LESS THAN (737081) ENGINE = InnoDB,\n PARTITION p201801SUB11 VALUES LESS THAN (737083) ENGINE = InnoDB,\n PARTITION p201801SUB12 VALUES LESS THAN (737085) ENGINE = InnoDB,\n PARTITION p201801SUB13 VALUES LESS THAN (737087) ENGINE = InnoDB,\n PARTITION p201801SUB14 VALUES LESS THAN (737089) ENGINE = InnoDB,\n PARTITION p201802SUB00 VALUES LESS THAN (737092) ENGINE = InnoDB,\n PARTITION p201802SUB01 VALUES LESS THAN (737094) ENGINE = InnoDB,\n PARTITION p201802SUB02 VALUES LESS THAN (737096) ENGINE = InnoDB,\n PARTITION p201802SUB03 VALUES LESS THAN (737098) ENGINE = InnoDB,\n PARTITION p201802SUB04 VALUES LESS THAN (737100) ENGINE = InnoDB,\n PARTITION p201802SUB05 VALUES LESS THAN (737102) ENGINE = InnoDB,\n PARTITION p201802SUB06 VALUES LESS THAN (737104) ENGINE = InnoDB,\n PARTITION p201802SUB07 VALUES LESS THAN (737106) ENGINE = InnoDB,\n PARTITION p201802SUB08 VALUES LESS THAN (737108) ENGINE = InnoDB,\n PARTITION p201802SUB09 VALUES LESS THAN (737110) ENGINE = InnoDB,\n PARTITION p201802SUB10 VALUES LESS THAN (737112) ENGINE = InnoDB,\n PARTITION p201802SUB11 VALUES LESS THAN (737114) ENGINE = InnoDB,\n PARTITION p201802SUB12 VALUES LESS THAN (737116) ENGINE = InnoDB,\n PARTITION p201802SUB13 VALUES LESS THAN (737118) ENGINE = InnoDB,\n PARTITION p201803SUB00 VALUES LESS THAN (737120) ENGINE = InnoDB,\n PARTITION p201803SUB01 VALUES LESS THAN (737122) ENGINE = InnoDB,\n PARTITION p201803SUB02 VALUES LESS THAN (737124) ENGINE = InnoDB,\n PARTITION p201803SUB03 VALUES LESS THAN (737126) ENGINE = InnoDB,\n PARTITION p201803SUB04 VALUES LESS THAN (737128) ENGINE = InnoDB,\n PARTITION p201803SUB05 VALUES LESS THAN (737130) ENGINE = InnoDB,\n PARTITION p201803SUB06 VALUES LESS THAN (737132) ENGINE = InnoDB,\n PARTITION p201803SUB07 VALUES LESS THAN (737134) ENGINE = InnoDB,\n PARTITION p201803SUB08 VALUES LESS THAN (737136) ENGINE = InnoDB,\n PARTITION p201803SUB09 VALUES LESS THAN (737138) ENGINE = InnoDB,\n PARTITION p201803SUB10 VALUES LESS THAN (737140) ENGINE = InnoDB,\n PARTITION p201803SUB11 VALUES LESS THAN (737142) ENGINE = InnoDB,\n PARTITION p201803SUB12 VALUES LESS THAN (737144) ENGINE = InnoDB,\n PARTITION p201803SUB13 VALUES LESS THAN (737146) ENGINE = InnoDB,\n PARTITION p201803SUB14 VALUES LESS THAN (737148) ENGINE = InnoDB,\n PARTITION p201804SUB00 VALUES LESS THAN (737151) ENGINE = InnoDB,\n PARTITION p201804SUB01 VALUES LESS THAN (737153) ENGINE = InnoDB,\n PARTITION p201804SUB02 VALUES LESS THAN (737155) ENGINE = InnoDB,\n PARTITION p201804SUB03 VALUES LESS THAN (737157) ENGINE = InnoDB,\n PARTITION p201804SUB04 VALUES LESS THAN (737159) ENGINE = InnoDB,\n PARTITION p201804SUB05 VALUES LESS THAN (737161) ENGINE = InnoDB,\n PARTITION p201804SUB06 VALUES LESS THAN (737163) ENGINE = InnoDB,\n PARTITION p201804SUB07 VALUES LESS THAN (737165) ENGINE = InnoDB,\n PARTITION p201804SUB08 VALUES LESS THAN (737167) ENGINE = InnoDB,\n PARTITION p201804SUB09 VALUES LESS THAN (737169) ENGINE = InnoDB,\n PARTITION p201804SUB10 VALUES LESS THAN (737171) ENGINE = InnoDB,\n PARTITION p201804SUB11 VALUES LESS THAN (737173) ENGINE = InnoDB,\n PARTITION p201804SUB12 VALUES LESS THAN (737175) ENGINE = InnoDB,\n PARTITION p201804SUB13 VALUES LESS THAN (737177) ENGINE = InnoDB,\n PARTITION p201804SUB14 VALUES LESS THAN (737179) ENGINE = InnoDB,\n PARTITION p201805SUB00 VALUES LESS THAN (737181) ENGINE = InnoDB,\n PARTITION p201805SUB01 VALUES LESS THAN (737183) ENGINE = InnoDB,\n PARTITION p201805SUB02 VALUES LESS THAN (737185) ENGINE = InnoDB,\n PARTITION p201805SUB03 VALUES LESS THAN (737187) ENGINE = InnoDB,\n PARTITION p201805SUB04 VALUES LESS THAN (737189) ENGINE = InnoDB,\n PARTITION p201805SUB05 VALUES LESS THAN (737191) ENGINE = InnoDB,\n PARTITION p201805SUB06 VALUES LESS THAN (737193) ENGINE = InnoDB,\n PARTITION p201805SUB07 VALUES LESS THAN (737195) ENGINE = InnoDB,\n PARTITION p201805SUB08 VALUES LESS THAN (737197) ENGINE = InnoDB,\n PARTITION p201805SUB09 VALUES LESS THAN (737199) ENGINE = InnoDB,\n PARTITION p201805SUB10 VALUES LESS THAN (737201) ENGINE = InnoDB,\n PARTITION p201805SUB11 VALUES LESS THAN (737203) ENGINE = InnoDB,\n PARTITION p201805SUB12 VALUES LESS THAN (737205) ENGINE = InnoDB,\n PARTITION p201805SUB13 VALUES LESS THAN (737207) ENGINE = InnoDB,\n PARTITION p201805SUB14 VALUES LESS THAN (737209) ENGINE = InnoDB,\n PARTITION p201806SUB00 VALUES LESS THAN (737212) ENGINE = InnoDB,\n PARTITION p201806SUB01 VALUES LESS THAN (737214) ENGINE = InnoDB,\n PARTITION p201806SUB02 VALUES LESS THAN (737216) ENGINE = InnoDB,\n PARTITION p201806SUB03 VALUES LESS THAN (737218) ENGINE = InnoDB,\n PARTITION p201806SUB04 VALUES LESS THAN (737220) ENGINE = InnoDB,\n PARTITION p201806SUB05 VALUES LESS THAN (737222) ENGINE = InnoDB,\n PARTITION p201806SUB06 VALUES LESS THAN (737224) ENGINE = InnoDB,\n PARTITION p201806SUB07 VALUES LESS THAN (737226) ENGINE = InnoDB,\n PARTITION p201806SUB08 VALUES LESS THAN (737228) ENGINE = InnoDB,\n PARTITION p201806SUB09 VALUES LESS THAN (737230) ENGINE = InnoDB,\n PARTITION p201806SUB10 VALUES LESS THAN (737232) ENGINE = InnoDB,\n PARTITION p201806SUB11 VALUES LESS THAN (737234) ENGINE = InnoDB,\n PARTITION p201806SUB12 VALUES LESS THAN (737236) ENGINE = InnoDB,\n PARTITION p201806SUB13 VALUES LESS THAN (737238) ENGINE = InnoDB,\n PARTITION p201806SUB14 VALUES LESS THAN (737240) ENGINE = InnoDB,\n PARTITION p201807SUB00 VALUES LESS THAN (737242) ENGINE = InnoDB,\n PARTITION p201807SUB01 VALUES LESS THAN (737244) ENGINE = InnoDB,\n PARTITION p201807SUB02 VALUES LESS THAN (737246) ENGINE = InnoDB,\n PARTITION p201807SUB03 VALUES LESS THAN (737248) ENGINE = InnoDB,\n PARTITION p201807SUB04 VALUES LESS THAN (737250) ENGINE = InnoDB,\n PARTITION p201807SUB05 VALUES LESS THAN (737252) ENGINE = InnoDB,\n PARTITION p201807SUB06 VALUES LESS THAN (737254) ENGINE = InnoDB,\n PARTITION p201807SUB07 VALUES LESS THAN (737256) ENGINE = InnoDB,\n PARTITION p201807SUB08 VALUES LESS THAN (737258) ENGINE = InnoDB,\n PARTITION p201807SUB09 VALUES LESS THAN (737260) ENGINE = InnoDB,\n PARTITION p201807SUB10 VALUES LESS THAN (737262) ENGINE = InnoDB,\n PARTITION p201807SUB11 VALUES LESS THAN (737264) ENGINE = InnoDB,\n PARTITION p201807SUB12 VALUES LESS THAN (737266) ENGINE = InnoDB,\n PARTITION p201807SUB13 VALUES LESS THAN (737268) ENGINE = InnoDB,\n PARTITION p201807SUB14 VALUES LESS THAN (737270) ENGINE = InnoDB,\n PARTITION p201808SUB00 VALUES LESS THAN (737273) ENGINE = InnoDB,\n PARTITION p201808SUB01 VALUES LESS THAN (737275) ENGINE = InnoDB,\n PARTITION p201808SUB02 VALUES LESS THAN (737277) ENGINE = InnoDB,\n PARTITION p201808SUB03 VALUES LESS THAN (737279) ENGINE = InnoDB,\n PARTITION p201808SUB04 VALUES LESS THAN (737281) ENGINE = InnoDB,\n PARTITION p201808SUB05 VALUES LESS THAN (737283) ENGINE = InnoDB,\n PARTITION p201808SUB06 VALUES LESS THAN (737285) ENGINE = InnoDB,\n PARTITION p201808SUB07 VALUES LESS THAN (737287) ENGINE = InnoDB,\n PARTITION p201808SUB08 VALUES LESS THAN (737289) ENGINE = InnoDB,\n PARTITION p201808SUB09 VALUES LESS THAN (737291) ENGINE = InnoDB,\n PARTITION p201808SUB10 VALUES LESS THAN (737293) ENGINE = InnoDB,\n PARTITION p201808SUB11 VALUES LESS THAN (737295) ENGINE = InnoDB,\n PARTITION p201808SUB12 VALUES LESS THAN (737297) ENGINE = InnoDB,\n PARTITION p201808SUB13 VALUES LESS THAN (737299) ENGINE = InnoDB,\n PARTITION p201808SUB14 VALUES LESS THAN (737301) ENGINE = InnoDB,\n PARTITION p201809SUB00 VALUES LESS THAN (737304) ENGINE = InnoDB,\n PARTITION p201809SUB01 VALUES LESS THAN (737306) ENGINE = InnoDB,\n PARTITION p201809SUB02 VALUES LESS THAN (737308) ENGINE = InnoDB,\n PARTITION p201809SUB03 VALUES LESS THAN (737310) ENGINE = InnoDB,\n PARTITION p201809SUB04 VALUES LESS THAN (737312) ENGINE = InnoDB,\n PARTITION p201809SUB05 VALUES LESS THAN (737314) ENGINE = InnoDB,\n PARTITION p201809SUB06 VALUES LESS THAN (737316) ENGINE = InnoDB,\n PARTITION p201809SUB07 VALUES LESS THAN (737318) ENGINE = InnoDB,\n PARTITION p201809SUB08 VALUES LESS THAN (737320) ENGINE = InnoDB,\n PARTITION p201809SUB09 VALUES LESS THAN (737322) ENGINE = InnoDB,\n PARTITION p201809SUB10 VALUES LESS THAN (737324) ENGINE = InnoDB,\n PARTITION p201809SUB11 VALUES LESS THAN (737326) ENGINE = InnoDB,\n PARTITION p201809SUB12 VALUES LESS THAN (737328) ENGINE = InnoDB,\n PARTITION p201809SUB13 VALUES LESS THAN (737330) ENGINE = InnoDB,\n PARTITION p201809SUB14 VALUES LESS THAN (737332) ENGINE = InnoDB,\n PARTITION p201810SUB00 VALUES LESS THAN (737334) ENGINE = InnoDB,\n PARTITION p201810SUB01 VALUES LESS THAN (737336) ENGINE = InnoDB,\n PARTITION p201810SUB02 VALUES LESS THAN (737338) ENGINE = InnoDB,\n PARTITION p201810SUB03 VALUES LESS THAN (737340) ENGINE = InnoDB,\n PARTITION p201810SUB04 VALUES LESS THAN (737342) ENGINE = InnoDB,\n PARTITION p201810SUB05 VALUES LESS THAN (737344) ENGINE = InnoDB,\n PARTITION p201810SUB06 VALUES LESS THAN (737346) ENGINE = InnoDB,\n PARTITION p201810SUB07 VALUES LESS THAN (737348) ENGINE = InnoDB,\n PARTITION p201810SUB08 VALUES LESS THAN (737350) ENGINE = InnoDB,\n PARTITION p201810SUB09 VALUES LESS THAN (737352) ENGINE = InnoDB,\n PARTITION p201810SUB10 VALUES LESS THAN (737354) ENGINE = InnoDB,\n PARTITION p201810SUB11 VALUES LESS THAN (737356) ENGINE = InnoDB,\n PARTITION p201810SUB12 VALUES LESS THAN (737358) ENGINE = InnoDB,\n PARTITION p201810SUB13 VALUES LESS THAN (737360) ENGINE = InnoDB,\n PARTITION p201810SUB14 VALUES LESS THAN (737362) ENGINE = InnoDB,\n PARTITION p201811SUB00 VALUES LESS THAN (737365) ENGINE = InnoDB,\n PARTITION p201811SUB01 VALUES LESS THAN (737367) ENGINE = InnoDB,\n PARTITION p201811SUB02 VALUES LESS THAN (737369) ENGINE = InnoDB,\n PARTITION p201811SUB03 VALUES LESS THAN (737371) ENGINE = InnoDB,\n PARTITION p201811SUB04 VALUES LESS THAN (737373) ENGINE = InnoDB,\n PARTITION p201811SUB05 VALUES LESS THAN (737375) ENGINE = InnoDB,\n PARTITION p201811SUB06 VALUES LESS THAN (737377) ENGINE = InnoDB,\n PARTITION p201811SUB07 VALUES LESS THAN (737379) ENGINE = InnoDB,\n PARTITION p201811SUB08 VALUES LESS THAN (737381) ENGINE = InnoDB,\n PARTITION p201811SUB09 VALUES LESS THAN (737383) ENGINE = InnoDB,\n PARTITION p201811SUB10 VALUES LESS THAN (737385) ENGINE = InnoDB,\n PARTITION p201811SUB11 VALUES LESS THAN (737387) ENGINE = InnoDB,\n PARTITION p201811SUB12 VALUES LESS THAN (737389) ENGINE = InnoDB,\n PARTITION p201811SUB13 VALUES LESS THAN (737391) ENGINE = InnoDB,\n PARTITION p201811SUB14 VALUES LESS THAN (737393) ENGINE = InnoDB,\n PARTITION p201812SUB00 VALUES LESS THAN (737395) ENGINE = InnoDB,\n PARTITION p201812SUB01 VALUES LESS THAN (737397) ENGINE = InnoDB,\n PARTITION p201812SUB02 VALUES LESS THAN (737399) ENGINE = InnoDB,\n PARTITION p201812SUB03 VALUES LESS THAN (737401) ENGINE = InnoDB,\n PARTITION p201812SUB04 VALUES LESS THAN (737403) ENGINE = InnoDB,\n PARTITION p201812SUB05 VALUES LESS THAN (737405) ENGINE = InnoDB,\n PARTITION p201812SUB06 VALUES LESS THAN (737407) ENGINE = InnoDB,\n PARTITION p201812SUB07 VALUES LESS THAN (737409) ENGINE = InnoDB,\n PARTITION p201812SUB08 VALUES LESS THAN (737411) ENGINE = InnoDB,\n PARTITION p201812SUB09 VALUES LESS THAN (737413) ENGINE = InnoDB,\n PARTITION p201812SUB10 VALUES LESS THAN (737415) ENGINE = InnoDB,\n PARTITION p201812SUB11 VALUES LESS THAN (737417) ENGINE = InnoDB,\n PARTITION p201812SUB12 VALUES LESS THAN (737419) ENGINE = InnoDB,\n PARTITION p201812SUB13 VALUES LESS THAN (737421) ENGINE = InnoDB,\n PARTITION p201812SUB14 VALUES LESS THAN (737423) ENGINE = InnoDB,\n PARTITION p201901SUB00 VALUES LESS THAN (737426) ENGINE = InnoDB,\n PARTITION p201901SUB01 VALUES LESS THAN (737428) ENGINE = InnoDB,\n PARTITION p201901SUB02 VALUES LESS THAN (737430) ENGINE = InnoDB,\n PARTITION p201901SUB03 VALUES LESS THAN (737432) ENGINE = InnoDB,\n PARTITION p201901SUB04 VALUES LESS THAN (737434) ENGINE = InnoDB,\n PARTITION p201901SUB05 VALUES LESS THAN (737436) ENGINE = InnoDB,\n PARTITION p201901SUB06 VALUES LESS THAN (737438) ENGINE = InnoDB,\n PARTITION p201901SUB07 VALUES LESS THAN (737440) ENGINE = InnoDB,\n PARTITION p201901SUB08 VALUES LESS THAN (737442) ENGINE = InnoDB,\n PARTITION p201901SUB09 VALUES LESS THAN (737444) ENGINE = InnoDB,\n PARTITION p201901SUB10 VALUES LESS THAN (737446) ENGINE = InnoDB,\n PARTITION p201901SUB11 VALUES LESS THAN (737448) ENGINE = InnoDB,\n PARTITION p201901SUB12 VALUES LESS THAN (737450) ENGINE = InnoDB,\n PARTITION p201901SUB13 VALUES LESS THAN (737452) ENGINE = InnoDB,\n PARTITION p201901SUB14 VALUES LESS THAN (737454) ENGINE = InnoDB,\n PARTITION p201902SUB00 VALUES LESS THAN (737457) ENGINE = InnoDB,\n PARTITION p201902SUB01 VALUES LESS THAN (737459) ENGINE = InnoDB,\n PARTITION p201902SUB02 VALUES LESS THAN (737461) ENGINE = InnoDB,\n PARTITION p201902SUB03 VALUES LESS THAN (737463) ENGINE = InnoDB,\n PARTITION p201902SUB04 VALUES LESS THAN (737465) ENGINE = InnoDB,\n PARTITION p201902SUB05 VALUES LESS THAN (737467) ENGINE = InnoDB,\n PARTITION p201902SUB06 VALUES LESS THAN (737469) ENGINE = InnoDB,\n PARTITION p201902SUB07 VALUES LESS THAN (737471) ENGINE = InnoDB,\n PARTITION p201902SUB08 VALUES LESS THAN (737473) ENGINE = InnoDB,\n PARTITION p201902SUB09 VALUES LESS THAN (737475) ENGINE = InnoDB,\n PARTITION p201902SUB10 VALUES LESS THAN (737477) ENGINE = InnoDB,\n PARTITION p201902SUB11 VALUES LESS THAN (737479) ENGINE = InnoDB,\n PARTITION p201902SUB12 VALUES LESS THAN (737481) ENGINE = InnoDB,\n PARTITION p201902SUB13 VALUES LESS THAN (737483) ENGINE = InnoDB,\n PARTITION p201903SUB00 VALUES LESS THAN (737485) ENGINE = InnoDB,\n PARTITION p201903SUB01 VALUES LESS THAN (737487) ENGINE = InnoDB,\n PARTITION p201903SUB02 VALUES LESS THAN (737489) ENGINE = InnoDB,\n PARTITION p201903SUB03 VALUES LESS THAN (737491) ENGINE = InnoDB,\n PARTITION p201903SUB04 VALUES LESS THAN (737493) ENGINE = InnoDB,\n PARTITION p201903SUB05 VALUES LESS THAN (737495) ENGINE = InnoDB,\n PARTITION p201903SUB06 VALUES LESS THAN (737497) ENGINE = InnoDB,\n PARTITION p201903SUB07 VALUES LESS THAN (737499) ENGINE = InnoDB,\n PARTITION p201903SUB08 VALUES LESS THAN (737501) ENGINE = InnoDB,\n PARTITION p201903SUB09 VALUES LESS THAN (737503) ENGINE = InnoDB,\n PARTITION p201903SUB10 VALUES LESS THAN (737505) ENGINE = InnoDB,\n PARTITION p201903SUB11 VALUES LESS THAN (737507) ENGINE = InnoDB,\n PARTITION p201903SUB12 VALUES LESS THAN (737509) ENGINE = InnoDB,\n PARTITION p201903SUB13 VALUES LESS THAN (737511) ENGINE = InnoDB,\n PARTITION p201903SUB14 VALUES LESS THAN (737513) ENGINE = InnoDB,\n PARTITION p201904SUB00 VALUES LESS THAN (737516) ENGINE = InnoDB,\n PARTITION p201904SUB01 VALUES LESS THAN (737518) ENGINE = InnoDB,\n PARTITION p201904SUB02 VALUES LESS THAN (737520) ENGINE = InnoDB,\n PARTITION p201904SUB03 VALUES LESS THAN (737522) ENGINE = InnoDB,\n PARTITION p201904SUB04 VALUES LESS THAN (737524) ENGINE = InnoDB,\n PARTITION p201904SUB05 VALUES LESS THAN (737526) ENGINE = InnoDB,\n PARTITION p201904SUB06 VALUES LESS THAN (737528) ENGINE = InnoDB,\n PARTITION p201904SUB07 VALUES LESS THAN (737530) ENGINE = InnoDB,\n PARTITION p201904SUB08 VALUES LESS THAN (737532) ENGINE = InnoDB,\n PARTITION p201904SUB09 VALUES LESS THAN (737534) ENGINE = InnoDB,\n PARTITION p201904SUB10 VALUES LESS THAN (737536) ENGINE = InnoDB,\n PARTITION p201904SUB11 VALUES LESS THAN (737538) ENGINE = InnoDB,\n PARTITION p201904SUB12 VALUES LESS THAN (737540) ENGINE = InnoDB,\n PARTITION p201904SUB13 VALUES LESS THAN (737542) ENGINE = InnoDB,\n PARTITION p201904SUB14 VALUES LESS THAN (737544) ENGINE = InnoDB,\n PARTITION p201905SUB00 VALUES LESS THAN (737546) ENGINE = InnoDB,\n PARTITION p201905SUB01 VALUES LESS THAN (737548) ENGINE = InnoDB,\n PARTITION p201905SUB02 VALUES LESS THAN (737550) ENGINE = InnoDB,\n PARTITION p201905SUB03 VALUES LESS THAN (737552) ENGINE = InnoDB,\n PARTITION p201905SUB04 VALUES LESS THAN (737554) ENGINE = InnoDB,\n PARTITION p201905SUB05 VALUES LESS THAN (737556) ENGINE = InnoDB,\n PARTITION p201905SUB06 VALUES LESS THAN (737558) ENGINE = InnoDB,\n PARTITION p201905SUB07 VALUES LESS THAN (737560) ENGINE = InnoDB,\n PARTITION p201905SUB08 VALUES LESS THAN (737562) ENGINE = InnoDB,\n PARTITION p201905SUB09 VALUES LESS THAN (737564) ENGINE = InnoDB,\n PARTITION p201905SUB10 VALUES LESS THAN (737566) ENGINE = InnoDB,\n PARTITION p201905SUB11 VALUES LESS THAN (737568) ENGINE = InnoDB,\n PARTITION p201905SUB12 VALUES LESS THAN (737570) ENGINE = InnoDB,\n PARTITION p201905SUB13 VALUES LESS THAN (737572) ENGINE = InnoDB,\n PARTITION p201905SUB14 VALUES LESS THAN (737574) ENGINE = InnoDB,\n PARTITION p201906SUB00 VALUES LESS THAN (737577) ENGINE = InnoDB,\n PARTITION p201906SUB01 VALUES LESS THAN (737579) ENGINE = InnoDB,\n PARTITION p201906SUB02 VALUES LESS THAN (737581) ENGINE = InnoDB,\n PARTITION p201906SUB03 VALUES LESS THAN (737583) ENGINE = InnoDB,\n PARTITION p201906SUB04 VALUES LESS THAN (737585) ENGINE = InnoDB,\n PARTITION p201906SUB05 VALUES LESS THAN (737587) ENGINE = InnoDB,\n PARTITION p201906SUB06 VALUES LESS THAN (737589) ENGINE = InnoDB,\n PARTITION p201906SUB07 VALUES LESS THAN (737591) ENGINE = InnoDB,\n PARTITION p201906SUB08 VALUES LESS THAN (737593) ENGINE = InnoDB,\n PARTITION p201906SUB09 VALUES LESS THAN (737595) ENGINE = InnoDB,\n PARTITION p201906SUB10 VALUES LESS THAN (737597) ENGINE = InnoDB,\n PARTITION p201906SUB11 VALUES LESS THAN (737599) ENGINE = InnoDB,\n PARTITION p201906SUB12 VALUES LESS THAN (737601) ENGINE = InnoDB,\n PARTITION p201906SUB13 VALUES LESS THAN (737603) ENGINE = InnoDB,\n PARTITION p201906SUB14 VALUES LESS THAN (737605) ENGINE = InnoDB,\n PARTITION p201907SUB00 VALUES LESS THAN (737607) ENGINE = InnoDB,\n PARTITION p201907SUB01 VALUES LESS THAN (737609) ENGINE = InnoDB,\n PARTITION p201907SUB02 VALUES LESS THAN (737611) ENGINE = InnoDB,\n PARTITION p201907SUB03 VALUES LESS THAN (737613) ENGINE = InnoDB,\n PARTITION p201907SUB04 VALUES LESS THAN (737615) ENGINE = InnoDB,\n PARTITION p201907SUB05 VALUES LESS THAN (737617) ENGINE = InnoDB,\n PARTITION p201907SUB06 VALUES LESS THAN (737619) ENGINE = InnoDB,\n PARTITION p201907SUB07 VALUES LESS THAN (737621) ENGINE = InnoDB,\n PARTITION p201907SUB08 VALUES LESS THAN (737623) ENGINE = InnoDB,\n PARTITION p201907SUB09 VALUES LESS THAN (737625) ENGINE = InnoDB,\n PARTITION p201907SUB10 VALUES LESS THAN (737627) ENGINE = InnoDB,\n PARTITION p201907SUB11 VALUES LESS THAN (737629) ENGINE = InnoDB,\n PARTITION p201907SUB12 VALUES LESS THAN (737631) ENGINE = InnoDB,\n PARTITION p201907SUB13 VALUES LESS THAN (737633) ENGINE = InnoDB,\n PARTITION p201907SUB14 VALUES LESS THAN (737635) ENGINE = InnoDB,\n PARTITION p201908SUB00 VALUES LESS THAN (737638) ENGINE = InnoDB,\n PARTITION p201908SUB01 VALUES LESS THAN (737640) ENGINE = InnoDB,\n PARTITION p201908SUB02 VALUES LESS THAN (737642) ENGINE = InnoDB,\n PARTITION p201908SUB03 VALUES LESS THAN (737644) ENGINE = InnoDB,\n PARTITION p201908SUB04 VALUES LESS THAN (737646) ENGINE = InnoDB,\n PARTITION p201908SUB05 VALUES LESS THAN (737648) ENGINE = InnoDB,\n PARTITION p201908SUB06 VALUES LESS THAN (737650) ENGINE = InnoDB,\n PARTITION p201908SUB07 VALUES LESS THAN (737652) ENGINE = InnoDB,\n PARTITION p201908SUB08 VALUES LESS THAN (737654) ENGINE = InnoDB,\n PARTITION p201908SUB09 VALUES LESS THAN (737656) ENGINE = InnoDB,\n PARTITION p201908SUB10 VALUES LESS THAN (737658) ENGINE = InnoDB,\n PARTITION p201908SUB11 VALUES LESS THAN (737660) ENGINE = InnoDB,\n PARTITION p201908SUB12 VALUES LESS THAN (737662) ENGINE = InnoDB,\n PARTITION p201908SUB13 VALUES LESS THAN (737664) ENGINE = InnoDB,\n PARTITION p201908SUB14 VALUES LESS THAN (737666) ENGINE = InnoDB,\n PARTITION p201909SUB00 VALUES LESS THAN (737669) ENGINE = InnoDB,\n PARTITION p201909SUB01 VALUES LESS THAN (737671) ENGINE = InnoDB,\n PARTITION p201909SUB02 VALUES LESS THAN (737673) ENGINE = InnoDB,\n PARTITION p201909SUB03 VALUES LESS THAN (737675) ENGINE = InnoDB,\n PARTITION p201909SUB04 VALUES LESS THAN (737677) ENGINE = InnoDB,\n PARTITION p201909SUB05 VALUES LESS THAN (737679) ENGINE = InnoDB,\n PARTITION p201909SUB06 VALUES LESS THAN (737681) ENGINE = InnoDB,\n PARTITION p201909SUB07 VALUES LESS THAN (737683) ENGINE = InnoDB,\n PARTITION p201909SUB08 VALUES LESS THAN (737685) ENGINE = InnoDB,\n PARTITION p201909SUB09 VALUES LESS THAN (737687) ENGINE = InnoDB,\n PARTITION p201909SUB10 VALUES LESS THAN (737689) ENGINE = InnoDB,\n PARTITION p201909SUB11 VALUES LESS THAN (737691) ENGINE = InnoDB,\n PARTITION p201909SUB12 VALUES LESS THAN (737693) ENGINE = InnoDB,\n PARTITION p201909SUB13 VALUES LESS THAN (737695) ENGINE = InnoDB,\n PARTITION p201909SUB14 VALUES LESS THAN (737697) ENGINE = InnoDB,\n PARTITION p201910SUB00 VALUES LESS THAN (737699) ENGINE = InnoDB,\n PARTITION p201910SUB01 VALUES LESS THAN (737701) ENGINE = InnoDB,\n PARTITION p201910SUB02 VALUES LESS THAN (737703) ENGINE = InnoDB,\n PARTITION p201910SUB03 VALUES LESS THAN (737705) ENGINE = InnoDB,\n PARTITION p201910SUB04 VALUES LESS THAN (737707) ENGINE = InnoDB,\n PARTITION p201910SUB05 VALUES LESS THAN (737709) ENGINE = InnoDB,\n PARTITION p201910SUB06 VALUES LESS THAN (737711) ENGINE = InnoDB,\n PARTITION p201910SUB07 VALUES LESS THAN (737713) ENGINE = InnoDB,\n PARTITION p201910SUB08 VALUES LESS THAN (737715) ENGINE = InnoDB,\n PARTITION p201910SUB09 VALUES LESS THAN (737717) ENGINE = InnoDB,\n PARTITION p201910SUB10 VALUES LESS THAN (737719) ENGINE = InnoDB,\n PARTITION p201910SUB11 VALUES LESS THAN (737721) ENGINE = InnoDB,\n PARTITION p201910SUB12 VALUES LESS THAN (737723) ENGINE = InnoDB,\n PARTITION p201910SUB13 VALUES LESS THAN (737725) ENGINE = InnoDB,\n PARTITION p201910SUB14 VALUES LESS THAN (737727) ENGINE = InnoDB,\n PARTITION p201911SUB00 VALUES LESS THAN (737730) ENGINE = InnoDB,\n PARTITION p201911SUB01 VALUES LESS THAN (737732) ENGINE = InnoDB,\n PARTITION p201911SUB02 VALUES LESS THAN (737734) ENGINE = InnoDB,\n PARTITION p201911SUB03 VALUES LESS THAN (737736) ENGINE = InnoDB,\n PARTITION p201911SUB04 VALUES LESS THAN (737738) ENGINE = InnoDB,\n PARTITION p201911SUB05 VALUES LESS THAN (737740) ENGINE = InnoDB,\n PARTITION p201911SUB06 VALUES LESS THAN (737742) ENGINE = InnoDB,\n PARTITION p201911SUB07 VALUES LESS THAN (737744) ENGINE = InnoDB,\n PARTITION p201911SUB08 VALUES LESS THAN (737746) ENGINE = InnoDB,\n PARTITION p201911SUB09 VALUES LESS THAN (737748) ENGINE = InnoDB,\n PARTITION p201911SUB10 VALUES LESS THAN (737750) ENGINE = InnoDB,\n PARTITION p201911SUB11 VALUES LESS THAN (737752) ENGINE = InnoDB,\n PARTITION p201911SUB12 VALUES LESS THAN (737754) ENGINE = InnoDB,\n PARTITION p201911SUB13 VALUES LESS THAN (737756) ENGINE = InnoDB,\n PARTITION p201911SUB14 VALUES LESS THAN (737758) ENGINE = InnoDB,\n PARTITION p201912SUB00 VALUES LESS THAN (737760) ENGINE = InnoDB,\n PARTITION p201912SUB01 VALUES LESS THAN (737762) ENGINE = InnoDB,\n PARTITION p201912SUB02 VALUES LESS THAN (737764) ENGINE = InnoDB,\n PARTITION p201912SUB03 VALUES LESS THAN (737766) ENGINE = InnoDB,\n PARTITION p201912SUB04 VALUES LESS THAN (737768) ENGINE = InnoDB,\n PARTITION p201912SUB05 VALUES LESS THAN (737770) ENGINE = InnoDB,\n PARTITION p201912SUB06 VALUES LESS THAN (737772) ENGINE = InnoDB,\n PARTITION p201912SUB07 VALUES LESS THAN (737774) ENGINE = InnoDB,\n PARTITION p201912SUB08 VALUES LESS THAN (737776) ENGINE = InnoDB,\n PARTITION p201912SUB09 VALUES LESS THAN (737778) ENGINE = InnoDB,\n PARTITION p201912SUB10 VALUES LESS THAN (737780) ENGINE = InnoDB,\n PARTITION p201912SUB11 VALUES LESS THAN (737782) ENGINE = InnoDB,\n PARTITION p201912SUB12 VALUES LESS THAN (737784) ENGINE = InnoDB,\n PARTITION p201912SUB13 VALUES LESS THAN (737786) ENGINE = InnoDB,\n PARTITION p201912SUB14 VALUES LESS THAN (737788) ENGINE = InnoDB,\n PARTITION p202001SUB00 VALUES LESS THAN (737791) ENGINE = InnoDB,\n PARTITION p202001SUB01 VALUES LESS THAN (737793) ENGINE = InnoDB,\n PARTITION p202001SUB02 VALUES LESS THAN (737795) ENGINE = InnoDB,\n PARTITION p202001SUB03 VALUES LESS THAN (737797) ENGINE = InnoDB,\n PARTITION p202001SUB04 VALUES LESS THAN (737799) ENGINE = InnoDB,\n PARTITION p202001SUB05 VALUES LESS THAN (737801) ENGINE = InnoDB,\n PARTITION p202001SUB06 VALUES LESS THAN (737803) ENGINE = InnoDB,\n PARTITION p202001SUB07 VALUES LESS THAN (737805) ENGINE = InnoDB,\n PARTITION p202001SUB08 VALUES LESS THAN (737807) ENGINE = InnoDB,\n PARTITION p202001SUB09 VALUES LESS THAN (737809) ENGINE = InnoDB,\n PARTITION p202001SUB10 VALUES LESS THAN (737811) ENGINE = InnoDB,\n PARTITION p202001SUB11 VALUES LESS THAN (737813) ENGINE = InnoDB,\n PARTITION p202001SUB12 VALUES LESS THAN (737815) ENGINE = InnoDB,\n PARTITION p202001SUB13 VALUES LESS THAN (737817) ENGINE = InnoDB,\n PARTITION p202001SUB14 VALUES LESS THAN (737819) ENGINE = InnoDB,\n PARTITION p202002SUB00 VALUES LESS THAN (737822) ENGINE = InnoDB,\n PARTITION p202002SUB01 VALUES LESS THAN (737824) ENGINE = InnoDB,\n PARTITION p202002SUB02 VALUES LESS THAN (737826) ENGINE = InnoDB,\n PARTITION p202002SUB03 VALUES LESS THAN (737828) ENGINE = InnoDB,\n PARTITION p202002SUB04 VALUES LESS THAN (737830) ENGINE = InnoDB,\n PARTITION p202002SUB05 VALUES LESS THAN (737832) ENGINE = InnoDB,\n PARTITION p202002SUB06 VALUES LESS THAN (737834) ENGINE = InnoDB,\n PARTITION p202002SUB07 VALUES LESS THAN (737836) ENGINE = InnoDB,\n PARTITION p202002SUB08 VALUES LESS THAN (737838) ENGINE = InnoDB,\n PARTITION p202002SUB09 VALUES LESS THAN (737840) ENGINE = InnoDB,\n PARTITION p202002SUB10 VALUES LESS THAN (737842) ENGINE = InnoDB,\n PARTITION p202002SUB11 VALUES LESS THAN (737844) ENGINE = InnoDB,\n PARTITION p202002SUB12 VALUES LESS THAN (737846) ENGINE = InnoDB,\n PARTITION p202002SUB13 VALUES LESS THAN (737848) ENGINE = InnoDB,\n PARTITION p202003SUB00 VALUES LESS THAN (737851) ENGINE = InnoDB,\n PARTITION p202003SUB01 VALUES LESS THAN (737853) ENGINE = InnoDB,\n PARTITION p202003SUB02 VALUES LESS THAN (737855) ENGINE = InnoDB,\n PARTITION p202003SUB03 VALUES LESS THAN (737857) ENGINE = InnoDB,\n PARTITION p202003SUB04 VALUES LESS THAN (737859) ENGINE = InnoDB,\n PARTITION p202003SUB05 VALUES LESS THAN (737861) ENGINE = InnoDB,\n PARTITION p202003SUB06 VALUES LESS THAN (737863) ENGINE = InnoDB,\n PARTITION p202003SUB07 VALUES LESS THAN (737865) ENGINE = InnoDB,\n PARTITION p202003SUB08 VALUES LESS THAN (737867) ENGINE = InnoDB,\n PARTITION p202003SUB09 VALUES LESS THAN (737869) ENGINE = InnoDB,\n PARTITION p202003SUB10 VALUES LESS THAN (737871) ENGINE = InnoDB,\n PARTITION p202003SUB11 VALUES LESS THAN (737873) ENGINE = InnoDB,\n PARTITION p202003SUB12 VALUES LESS THAN (737875) ENGINE = InnoDB,\n PARTITION p202003SUB13 VALUES LESS THAN (737877) ENGINE = InnoDB,\n PARTITION p202003SUB14 VALUES LESS THAN (737879) ENGINE = InnoDB,\n PARTITION p202004SUB00 VALUES LESS THAN (737882) ENGINE = InnoDB,\n PARTITION p202004SUB01 VALUES LESS THAN (737884) ENGINE = InnoDB,\n PARTITION p202004SUB02 VALUES LESS THAN (737886) ENGINE = InnoDB,\n PARTITION p202004SUB03 VALUES LESS THAN (737888) ENGINE = InnoDB,\n PARTITION p202004SUB04 VALUES LESS THAN (737890) ENGINE = InnoDB,\n PARTITION p202004SUB05 VALUES LESS THAN (737892) ENGINE = InnoDB,\n PARTITION p202004SUB06 VALUES LESS THAN (737894) ENGINE = InnoDB,\n PARTITION p202004SUB07 VALUES LESS THAN (737896) ENGINE = InnoDB,\n PARTITION p202004SUB08 VALUES LESS THAN (737898) ENGINE = InnoDB,\n PARTITION p202004SUB09 VALUES LESS THAN (737900) ENGINE = InnoDB,\n PARTITION p202004SUB10 VALUES LESS THAN (737902) ENGINE = InnoDB,\n PARTITION p202004SUB11 VALUES LESS THAN (737904) ENGINE = InnoDB,\n PARTITION p202004SUB12 VALUES LESS THAN (737906) ENGINE = InnoDB,\n PARTITION p202004SUB13 VALUES LESS THAN (737908) ENGINE = InnoDB,\n PARTITION p202004SUB14 VALUES LESS THAN (737910) ENGINE = InnoDB,\n PARTITION p202005SUB00 VALUES LESS THAN (737912) ENGINE = InnoDB,\n PARTITION p202005SUB01 VALUES LESS THAN (737914) ENGINE = InnoDB,\n PARTITION p202005SUB02 VALUES LESS THAN (737916) ENGINE = InnoDB,\n PARTITION p202005SUB03 VALUES LESS THAN (737918) ENGINE = InnoDB,\n PARTITION p202005SUB04 VALUES LESS THAN (737920) ENGINE = InnoDB,\n PARTITION p202005SUB05 VALUES LESS THAN (737922) ENGINE = InnoDB,\n PARTITION p202005SUB06 VALUES LESS THAN (737924) ENGINE = InnoDB,\n PARTITION p202005SUB07 VALUES LESS THAN (737926) ENGINE = InnoDB,\n PARTITION p202005SUB08 VALUES LESS THAN (737928) ENGINE = InnoDB,\n PARTITION p202005SUB09 VALUES LESS THAN (737930) ENGINE = InnoDB,\n PARTITION p202005SUB10 VALUES LESS THAN (737932) ENGINE = InnoDB,\n PARTITION p202005SUB11 VALUES LESS THAN (737934) ENGINE = InnoDB,\n PARTITION p202005SUB12 VALUES LESS THAN (737936) ENGINE = InnoDB,\n PARTITION p202005SUB13 VALUES LESS THAN (737938) ENGINE = InnoDB,\n PARTITION p202005SUB14 VALUES LESS THAN (737940) ENGINE = InnoDB,\n PARTITION p202006SUB00 VALUES LESS THAN (737943) ENGINE = InnoDB,\n PARTITION p202006SUB01 VALUES LESS THAN (737945) ENGINE = InnoDB,\n PARTITION p202006SUB02 VALUES LESS THAN (737947) ENGINE = InnoDB,\n PARTITION p202006SUB03 VALUES LESS THAN (737949) ENGINE = InnoDB,\n PARTITION p202006SUB04 VALUES LESS THAN (737951) ENGINE = InnoDB,\n PARTITION p202006SUB05 VALUES LESS THAN (737953) ENGINE = InnoDB,\n PARTITION p202006SUB06 VALUES LESS THAN (737955) ENGINE = InnoDB,\n PARTITION p202006SUB07 VALUES LESS THAN (737957) ENGINE = InnoDB,\n PARTITION p202006SUB08 VALUES LESS THAN (737959) ENGINE = InnoDB,\n PARTITION p202006SUB09 VALUES LESS THAN (737961) ENGINE = InnoDB,\n PARTITION p202006SUB10 VALUES LESS THAN (737963) ENGINE = InnoDB,\n PARTITION p202006SUB11 VALUES LESS THAN (737965) ENGINE = InnoDB,\n PARTITION p202006SUB12 VALUES LESS THAN (737967) ENGINE = InnoDB,\n PARTITION p202006SUB13 VALUES LESS THAN (737969) ENGINE = InnoDB,\n PARTITION p202006SUB14 VALUES LESS THAN (737971) ENGINE = InnoDB,\n PARTITION p202007SUB00 VALUES LESS THAN (737973) ENGINE = InnoDB,\n PARTITION p202007SUB01 VALUES LESS THAN (737975) ENGINE = InnoDB,\n PARTITION p202007SUB02 VALUES LESS THAN (737977) ENGINE = InnoDB,\n PARTITION p202007SUB03 VALUES LESS THAN (737979) ENGINE = InnoDB,\n PARTITION p202007SUB04 VALUES LESS THAN (737981) ENGINE = InnoDB,\n PARTITION p202007SUB05 VALUES LESS THAN (737983) ENGINE = InnoDB,\n PARTITION p202007SUB06 VALUES LESS THAN (737985) ENGINE = InnoDB,\n PARTITION p202007SUB07 VALUES LESS THAN (737987) ENGINE = InnoDB,\n PARTITION p202007SUB08 VALUES LESS THAN (737989) ENGINE = InnoDB,\n PARTITION p202007SUB09 VALUES LESS THAN (737991) ENGINE = InnoDB,\n PARTITION p202007SUB10 VALUES LESS THAN (737993) ENGINE = InnoDB,\n PARTITION p202007SUB11 VALUES LESS THAN (737995) ENGINE = InnoDB,\n PARTITION p202007SUB12 VALUES LESS THAN (737997) ENGINE = InnoDB,\n PARTITION p202007SUB13 VALUES LESS THAN (737999) ENGINE = InnoDB,\n PARTITION p202007SUB14 VALUES LESS THAN (738001) ENGINE = InnoDB,\n PARTITION p202008SUB00 VALUES LESS THAN (738004) ENGINE = InnoDB,\n PARTITION p202008SUB01 VALUES LESS THAN (738006) ENGINE = InnoDB,\n PARTITION p202008SUB02 VALUES LESS THAN (738008) ENGINE = InnoDB,\n PARTITION p202008SUB03 VALUES LESS THAN (738010) ENGINE = InnoDB,\n PARTITION p202008SUB04 VALUES LESS THAN (738012) ENGINE = InnoDB,\n PARTITION p202008SUB05 VALUES LESS THAN (738014) ENGINE = InnoDB,\n PARTITION p202008SUB06 VALUES LESS THAN (738016) ENGINE = InnoDB,\n PARTITION p202008SUB07 VALUES LESS THAN (738018) ENGINE = InnoDB,\n PARTITION p202008SUB08 VALUES LESS THAN (738020) ENGINE = InnoDB,\n PARTITION p202008SUB09 VALUES LESS THAN (738022) ENGINE = InnoDB,\n PARTITION p202008SUB10 VALUES LESS THAN (738024) ENGINE = InnoDB,\n PARTITION p202008SUB11 VALUES LESS THAN (738026) ENGINE = InnoDB,\n PARTITION p202008SUB12 VALUES LESS THAN (738028) ENGINE = InnoDB,\n PARTITION p202008SUB13 VALUES LESS THAN (738030) ENGINE = InnoDB,\n PARTITION p202008SUB14 VALUES LESS THAN (738032) ENGINE = InnoDB,\n PARTITION p202009SUB00 VALUES LESS THAN (738035) ENGINE = InnoDB,\n PARTITION p202009SUB01 VALUES LESS THAN (738037) ENGINE = InnoDB,\n PARTITION p202009SUB02 VALUES LESS THAN (738039) ENGINE = InnoDB,\n PARTITION p202009SUB03 VALUES LESS THAN (738041) ENGINE = InnoDB,\n PARTITION p202009SUB04 VALUES LESS THAN (738043) ENGINE = InnoDB,\n PARTITION p202009SUB05 VALUES LESS THAN (738045) ENGINE = InnoDB,\n PARTITION p202009SUB06 VALUES LESS THAN (738047) ENGINE = InnoDB,\n PARTITION p202009SUB07 VALUES LESS THAN (738049) ENGINE = InnoDB,\n PARTITION p202009SUB08 VALUES LESS THAN (738051) ENGINE = InnoDB,\n PARTITION p202009SUB09 VALUES LESS THAN (738053) ENGINE = InnoDB,\n PARTITION p202009SUB10 VALUES LESS THAN (738055) ENGINE = InnoDB,\n PARTITION p202009SUB11 VALUES LESS THAN (738057) ENGINE = InnoDB,\n PARTITION p202009SUB12 VALUES LESS THAN (738059) ENGINE = InnoDB,\n PARTITION p202009SUB13 VALUES LESS THAN (738061) ENGINE = InnoDB,\n PARTITION p202009SUB14 VALUES LESS THAN (738063) ENGINE = InnoDB,\n PARTITION p202010SUB00 VALUES LESS THAN (738065) ENGINE = InnoDB,\n PARTITION p202010SUB01 VALUES LESS THAN (738067) ENGINE = InnoDB,\n PARTITION p202010SUB02 VALUES LESS THAN (738069) ENGINE = InnoDB,\n PARTITION p202010SUB03 VALUES LESS THAN (738071) ENGINE = InnoDB,\n PARTITION p202010SUB04 VALUES LESS THAN (738073) ENGINE = InnoDB,\n PARTITION p202010SUB05 VALUES LESS THAN (738075) ENGINE = InnoDB,\n PARTITION p202010SUB06 VALUES LESS THAN (738077) ENGINE = InnoDB,\n PARTITION p202010SUB07 VALUES LESS THAN (738079) ENGINE = InnoDB,\n PARTITION p202010SUB08 VALUES LESS THAN (738081) ENGINE = InnoDB,\n PARTITION p202010SUB09 VALUES LESS THAN (738083) ENGINE = InnoDB,\n PARTITION p202010SUB10 VALUES LESS THAN (738085) ENGINE = InnoDB,\n PARTITION p202010SUB11 VALUES LESS THAN (738087) ENGINE = InnoDB,\n PARTITION p202010SUB12 VALUES LESS THAN (738089) ENGINE = InnoDB,\n PARTITION p202010SUB13 VALUES LESS THAN (738091) ENGINE = InnoDB,\n PARTITION p202010SUB14 VALUES LESS THAN (738093) ENGINE = InnoDB,\n PARTITION p202011SUB00 VALUES LESS THAN (738096) ENGINE = InnoDB,\n PARTITION p202011SUB01 VALUES LESS THAN (738098) ENGINE = InnoDB,\n PARTITION p202011SUB02 VALUES LESS THAN (738100) ENGINE = InnoDB,\n PARTITION p202011SUB03 VALUES LESS THAN (738102) ENGINE = InnoDB,\n PARTITION p202011SUB04 VALUES LESS THAN (738104) ENGINE = InnoDB,\n PARTITION p202011SUB05 VALUES LESS THAN (738106) ENGINE = InnoDB,\n PARTITION p202011SUB06 VALUES LESS THAN (738108) ENGINE = InnoDB,\n PARTITION p202011SUB07 VALUES LESS THAN (738110) ENGINE = InnoDB,\n PARTITION p202011SUB08 VALUES LESS THAN (738112) ENGINE = InnoDB,\n PARTITION p202011SUB09 VALUES LESS THAN (738114) ENGINE = InnoDB,\n PARTITION p202011SUB10 VALUES LESS THAN (738116) ENGINE = InnoDB,\n PARTITION p202011SUB11 VALUES LESS THAN (738118) ENGINE = InnoDB,\n PARTITION p202011SUB12 VALUES LESS THAN (738120) ENGINE = InnoDB,\n PARTITION p202011SUB13 VALUES LESS THAN (738122) ENGINE = InnoDB,\n PARTITION p202011SUB14 VALUES LESS THAN (738124) ENGINE = InnoDB,\n PARTITION p202012SUB00 VALUES LESS THAN (738126) ENGINE = InnoDB,\n PARTITION p202012SUB01 VALUES LESS THAN (738128) ENGINE = InnoDB,\n PARTITION p202012SUB02 VALUES LESS THAN (738130) ENGINE = InnoDB,\n PARTITION p202012SUB03 VALUES LESS THAN (738132) ENGINE = InnoDB,\n PARTITION p202012SUB04 VALUES LESS THAN (738134) ENGINE = InnoDB,\n PARTITION p202012SUB05 VALUES LESS THAN (738136) ENGINE = InnoDB,\n PARTITION p202012SUB06 VALUES LESS THAN (738138) ENGINE = InnoDB,\n PARTITION p202012SUB07 VALUES LESS THAN (738140) ENGINE = InnoDB,\n PARTITION p202012SUB08 VALUES LESS THAN (738142) ENGINE = InnoDB,\n PARTITION p202012SUB09 VALUES LESS THAN (738144) ENGINE = InnoDB,\n PARTITION p202012SUB10 VALUES LESS THAN (738146) ENGINE = InnoDB,\n PARTITION p202012SUB11 VALUES LESS THAN (738148) ENGINE = InnoDB,\n PARTITION p202012SUB12 VALUES LESS THAN (738150) ENGINE = InnoDB,\n PARTITION p202012SUB13 VALUES LESS THAN (738152) ENGINE = InnoDB,\n PARTITION p202012SUB14 VALUES LESS THAN (738154) ENGINE = InnoDB,\n PARTITION p202101SUB00 VALUES LESS THAN (738157) ENGINE = InnoDB,\n PARTITION p202101SUB01 VALUES LESS THAN (738159) ENGINE = InnoDB,\n PARTITION p202101SUB02 VALUES LESS THAN (738161) ENGINE = InnoDB,\n PARTITION p202101SUB03 VALUES LESS THAN (738163) ENGINE = InnoDB,\n PARTITION p202101SUB04 VALUES LESS THAN (738165) ENGINE = InnoDB,\n PARTITION p202101SUB05 VALUES LESS THAN (738167) ENGINE = InnoDB,\n PARTITION p202101SUB06 VALUES LESS THAN (738169) ENGINE = InnoDB,\n PARTITION p202101SUB07 VALUES LESS THAN (738171) ENGINE = InnoDB,\n PARTITION p202101SUB08 VALUES LESS THAN (738173) ENGINE = InnoDB,\n PARTITION p202101SUB09 VALUES LESS THAN (738175) ENGINE = InnoDB,\n PARTITION p202101SUB10 VALUES LESS THAN (738177) ENGINE = InnoDB,\n PARTITION p202101SUB11 VALUES LESS THAN (738179) ENGINE = InnoDB,\n PARTITION p202101SUB12 VALUES LESS THAN (738181) ENGINE = InnoDB,\n PARTITION p202101SUB13 VALUES LESS THAN (738183) ENGINE = InnoDB,\n PARTITION p202101SUB14 VALUES LESS THAN (738185) ENGINE = InnoDB,\n PARTITION p202102SUB00 VALUES LESS THAN (738188) ENGINE = InnoDB,\n PARTITION p202102SUB01 VALUES LESS THAN (738190) ENGINE = InnoDB,\n PARTITION p202102SUB02 VALUES LESS THAN (738192) ENGINE = InnoDB,\n PARTITION p202102SUB03 VALUES LESS THAN (738194) ENGINE = InnoDB,\n PARTITION p202102SUB04 VALUES LESS THAN (738196) ENGINE = InnoDB,\n PARTITION p202102SUB05 VALUES LESS THAN (738198) ENGINE = InnoDB,\n PARTITION p202102SUB06 VALUES LESS THAN (738200) ENGINE = InnoDB,\n PARTITION p202102SUB07 VALUES LESS THAN (738202) ENGINE = InnoDB,\n PARTITION p202102SUB08 VALUES LESS THAN (738204) ENGINE = InnoDB,\n PARTITION p202102SUB09 VALUES LESS THAN (738206) ENGINE = InnoDB,\n PARTITION p202102SUB10 VALUES LESS THAN (738208) ENGINE = InnoDB,\n PARTITION p202102SUB11 VALUES LESS THAN (738210) ENGINE = InnoDB,\n PARTITION p202102SUB12 VALUES LESS THAN (738212) ENGINE = InnoDB,\n PARTITION p202102SUB13 VALUES LESS THAN (738214) ENGINE = InnoDB,\n PARTITION p202103SUB00 VALUES LESS THAN (738216) ENGINE = InnoDB,\n PARTITION p202103SUB01 VALUES LESS THAN (738218) ENGINE = InnoDB,\n PARTITION p202103SUB02 VALUES LESS THAN (738220) ENGINE = InnoDB,\n PARTITION p202103SUB03 VALUES LESS THAN (738222) ENGINE = InnoDB,\n PARTITION p202103SUB04 VALUES LESS THAN (738224) ENGINE = InnoDB,\n PARTITION p202103SUB05 VALUES LESS THAN (738226) ENGINE = InnoDB,\n PARTITION p202103SUB06 VALUES LESS THAN (738228) ENGINE = InnoDB,\n PARTITION p202103SUB07 VALUES LESS THAN (738230) ENGINE = InnoDB,\n PARTITION p202103SUB08 VALUES LESS THAN (738232) ENGINE = InnoDB,\n PARTITION p202103SUB09 VALUES LESS THAN (738234) ENGINE = InnoDB,\n PARTITION p202103SUB10 VALUES LESS THAN (738236) ENGINE = InnoDB,\n PARTITION p202103SUB11 VALUES LESS THAN (738238) ENGINE = InnoDB,\n PARTITION p202103SUB12 VALUES LESS THAN (738240) ENGINE = InnoDB,\n PARTITION p202103SUB13 VALUES LESS THAN (738242) ENGINE = InnoDB,\n PARTITION p202103SUB14 VALUES LESS THAN (738244) ENGINE = InnoDB,\n PARTITION p202104SUB00 VALUES LESS THAN (738247) ENGINE = InnoDB,\n PARTITION p202104SUB01 VALUES LESS THAN (738249) ENGINE = InnoDB,\n PARTITION p202104SUB02 VALUES LESS THAN (738251) ENGINE = InnoDB,\n PARTITION p202104SUB03 VALUES LESS THAN (738253) ENGINE = InnoDB,\n PARTITION p202104SUB04 VALUES LESS THAN (738255) ENGINE = InnoDB,\n PARTITION p202104SUB05 VALUES LESS THAN (738257) ENGINE = InnoDB,\n PARTITION p202104SUB06 VALUES LESS THAN (738259) ENGINE = InnoDB,\n PARTITION p202104SUB07 VALUES LESS THAN (738261) ENGINE = InnoDB,\n PARTITION p202104SUB08 VALUES LESS THAN (738263) ENGINE = InnoDB,\n PARTITION p202104SUB09 VALUES LESS THAN (738265) ENGINE = InnoDB,\n PARTITION p202104SUB10 VALUES LESS THAN (738267) ENGINE = InnoDB,\n PARTITION p202104SUB11 VALUES LESS THAN (738269) ENGINE = InnoDB,\n PARTITION p202104SUB12 VALUES LESS THAN (738271) ENGINE = InnoDB,\n PARTITION p202104SUB13 VALUES LESS THAN (738273) ENGINE = InnoDB,\n PARTITION p202104SUB14 VALUES LESS THAN (738275) ENGINE = InnoDB,\n PARTITION p202105SUB00 VALUES LESS THAN (738277) ENGINE = InnoDB,\n PARTITION p202105SUB01 VALUES LESS THAN (738279) ENGINE = InnoDB,\n PARTITION p202105SUB02 VALUES LESS THAN (738281) ENGINE = InnoDB,\n PARTITION p202105SUB03 VALUES LESS THAN (738283) ENGINE = InnoDB,\n PARTITION p202105SUB04 VALUES LESS THAN (738285) ENGINE = InnoDB,\n PARTITION p202105SUB05 VALUES LESS THAN (738287) ENGINE = InnoDB,\n PARTITION p202105SUB06 VALUES LESS THAN (738289) ENGINE = InnoDB,\n PARTITION p202105SUB07 VALUES LESS THAN (738291) ENGINE = InnoDB,\n PARTITION p202105SUB08 VALUES LESS THAN (738293) ENGINE = InnoDB,\n PARTITION p202105SUB09 VALUES LESS THAN (738295) ENGINE = InnoDB,\n PARTITION p202105SUB10 VALUES LESS THAN (738297) ENGINE = InnoDB,\n PARTITION p202105SUB11 VALUES LESS THAN (738299) ENGINE = InnoDB,\n PARTITION p202105SUB12 VALUES LESS THAN (738301) ENGINE = InnoDB,\n PARTITION p202105SUB13 VALUES LESS THAN (738303) ENGINE = InnoDB,\n PARTITION p202105SUB14 VALUES LESS THAN (738305) ENGINE = InnoDB,\n PARTITION p202106SUB00 VALUES LESS THAN (738308) ENGINE = InnoDB,\n PARTITION p202106SUB01 VALUES LESS THAN (738310) ENGINE = InnoDB,\n PARTITION p202106SUB02 VALUES LESS THAN (738312) ENGINE = InnoDB,\n PARTITION p202106SUB03 VALUES LESS THAN (738314) ENGINE = InnoDB,\n PARTITION p202106SUB04 VALUES LESS THAN (738316) ENGINE = InnoDB,\n PARTITION p202106SUB05 VALUES LESS THAN (738318) ENGINE = InnoDB,\n PARTITION p202106SUB06 VALUES LESS THAN (738320) ENGINE = InnoDB,\n PARTITION p202106SUB07 VALUES LESS THAN (738322) ENGINE = InnoDB,\n PARTITION p202106SUB08 VALUES LESS THAN (738324) ENGINE = InnoDB,\n PARTITION p202106SUB09 VALUES LESS THAN (738326) ENGINE = InnoDB,\n PARTITION p202106SUB10 VALUES LESS THAN (738328) ENGINE = InnoDB,\n PARTITION p202106SUB11 VALUES LESS THAN (738330) ENGINE = InnoDB,\n PARTITION p202106SUB12 VALUES LESS THAN (738332) ENGINE = InnoDB,\n PARTITION p202106SUB13 VALUES LESS THAN (738334) ENGINE = InnoDB,\n PARTITION p202106SUB14 VALUES LESS THAN (738336) ENGINE = InnoDB,\n PARTITION p202107SUB00 VALUES LESS THAN (738338) ENGINE = InnoDB,\n PARTITION p202107SUB01 VALUES LESS THAN (738340) ENGINE = InnoDB,\n PARTITION p202107SUB02 VALUES LESS THAN (738342) ENGINE = InnoDB,\n PARTITION p202107SUB03 VALUES LESS THAN (738344) ENGINE = InnoDB,\n PARTITION p202107SUB04 VALUES LESS THAN (738346) ENGINE = InnoDB,\n PARTITION p202107SUB05 VALUES LESS THAN (738348) ENGINE = InnoDB,\n PARTITION p202107SUB06 VALUES LESS THAN (738350) ENGINE = InnoDB,\n PARTITION p202107SUB07 VALUES LESS THAN (738352) ENGINE = InnoDB,\n PARTITION p202107SUB08 VALUES LESS THAN (738354) ENGINE = InnoDB,\n PARTITION p202107SUB09 VALUES LESS THAN (738356) ENGINE = InnoDB,\n PARTITION p202107SUB10 VALUES LESS THAN (738358) ENGINE = InnoDB,\n PARTITION p202107SUB11 VALUES LESS THAN (738360) ENGINE = InnoDB,\n PARTITION p202107SUB12 VALUES LESS THAN (738362) ENGINE = InnoDB,\n PARTITION p202107SUB13 VALUES LESS THAN (738364) ENGINE = InnoDB,\n PARTITION p202107SUB14 VALUES LESS THAN (738366) ENGINE = InnoDB,\n PARTITION p202108SUB00 VALUES LESS THAN (738369) ENGINE = InnoDB,\n PARTITION p202108SUB01 VALUES LESS THAN (738371) ENGINE = InnoDB,\n PARTITION p202108SUB02 VALUES LESS THAN (738373) ENGINE = InnoDB,\n PARTITION p202108SUB03 VALUES LESS THAN (738375) ENGINE = InnoDB,\n PARTITION p202108SUB04 VALUES LESS THAN (738377) ENGINE = InnoDB,\n PARTITION p202108SUB05 VALUES LESS THAN (738379) ENGINE = InnoDB,\n PARTITION p202108SUB06 VALUES LESS THAN (738381) ENGINE = InnoDB,\n PARTITION p202108SUB07 VALUES LESS THAN (738383) ENGINE = InnoDB,\n PARTITION p202108SUB08 VALUES LESS THAN (738385) ENGINE = InnoDB,\n PARTITION p202108SUB09 VALUES LESS THAN (738387) ENGINE = InnoDB,\n PARTITION p202108SUB10 VALUES LESS THAN (738389) ENGINE = InnoDB,\n PARTITION p202108SUB11 VALUES LESS THAN (738391) ENGINE = InnoDB,\n PARTITION p202108SUB12 VALUES LESS THAN (738393) ENGINE = InnoDB,\n PARTITION p202108SUB13 VALUES LESS THAN (738395) ENGINE = InnoDB,\n PARTITION p202108SUB14 VALUES LESS THAN (738397) ENGINE = InnoDB,\n PARTITION p202109SUB00 VALUES LESS THAN (738400) ENGINE = InnoDB,\n PARTITION p202109SUB01 VALUES LESS THAN (738402) ENGINE = InnoDB,\n PARTITION p202109SUB02 VALUES LESS THAN (738404) ENGINE = InnoDB,\n PARTITION p202109SUB03 VALUES LESS THAN (738406) ENGINE = InnoDB,\n PARTITION p202109SUB04 VALUES LESS THAN (738408) ENGINE = InnoDB,\n PARTITION p202109SUB05 VALUES LESS THAN (738410) ENGINE = InnoDB,\n PARTITION p202109SUB06 VALUES LESS THAN (738412) ENGINE = InnoDB,\n PARTITION p202109SUB07 VALUES LESS THAN (738414) ENGINE = InnoDB,\n PARTITION p202109SUB08 VALUES LESS THAN (738416) ENGINE = InnoDB,\n PARTITION p202109SUB09 VALUES LESS THAN (738418) ENGINE = InnoDB,\n PARTITION p202109SUB10 VALUES LESS THAN (738420) ENGINE = InnoDB,\n PARTITION p202109SUB11 VALUES LESS THAN (738422) ENGINE = InnoDB,\n PARTITION p202109SUB12 VALUES LESS THAN (738424) ENGINE = InnoDB,\n PARTITION p202109SUB13 VALUES LESS THAN (738426) ENGINE = InnoDB,\n PARTITION p202109SUB14 VALUES LESS THAN (738428) ENGINE = InnoDB,\n PARTITION p202110SUB00 VALUES LESS THAN (738430) ENGINE = InnoDB,\n PARTITION p202110SUB01 VALUES LESS THAN (738432) ENGINE = InnoDB,\n PARTITION p202110SUB02 VALUES LESS THAN (738434) ENGINE = InnoDB,\n PARTITION p202110SUB03 VALUES LESS THAN (738436) ENGINE = InnoDB,\n PARTITION p202110SUB04 VALUES LESS THAN (738438) ENGINE = InnoDB,\n PARTITION p202110SUB05 VALUES LESS THAN (738440) ENGINE = InnoDB,\n PARTITION p202110SUB06 VALUES LESS THAN (738442) ENGINE = InnoDB,\n PARTITION p202110SUB07 VALUES LESS THAN (738444) ENGINE = InnoDB,\n PARTITION p202110SUB08 VALUES LESS THAN (738446) ENGINE = InnoDB,\n PARTITION p202110SUB09 VALUES LESS THAN (738448) ENGINE = InnoDB,\n PARTITION p202110SUB10 VALUES LESS THAN (738450) ENGINE = InnoDB,\n PARTITION p202110SUB11 VALUES LESS THAN (738452) ENGINE = InnoDB,\n PARTITION p202110SUB12 VALUES LESS THAN (738454) ENGINE = InnoDB,\n PARTITION p202110SUB13 VALUES LESS THAN (738456) ENGINE = InnoDB,\n PARTITION p202110SUB14 VALUES LESS THAN (738458) ENGINE = InnoDB,\n PARTITION p202111SUB00 VALUES LESS THAN (738461) ENGINE = InnoDB,\n PARTITION p202111SUB01 VALUES LESS THAN (738463) ENGINE = InnoDB,\n PARTITION p202111SUB02 VALUES LESS THAN (738465) ENGINE = InnoDB,\n PARTITION p202111SUB03 VALUES LESS THAN (738467) ENGINE = InnoDB,\n PARTITION p202111SUB04 VALUES LESS THAN (738469) ENGINE = InnoDB,\n PARTITION p202111SUB05 VALUES LESS THAN (738471) ENGINE = InnoDB,\n PARTITION p202111SUB06 VALUES LESS THAN (738473) ENGINE = InnoDB,\n PARTITION p202111SUB07 VALUES LESS THAN (738475) ENGINE = InnoDB,\n PARTITION p202111SUB08 VALUES LESS THAN (738477) ENGINE = InnoDB,\n PARTITION p202111SUB09 VALUES LESS THAN (738479) ENGINE = InnoDB,\n PARTITION p202111SUB10 VALUES LESS THAN (738481) ENGINE = InnoDB,\n PARTITION p202111SUB11 VALUES LESS THAN (738483) ENGINE = InnoDB,\n PARTITION p202111SUB12 VALUES LESS THAN (738485) ENGINE = InnoDB,\n PARTITION p202111SUB13 VALUES LESS THAN (738487) ENGINE = InnoDB,\n PARTITION p202111SUB14 VALUES LESS THAN (738489) ENGINE = InnoDB,\n PARTITION p202112SUB00 VALUES LESS THAN (738491) ENGINE = InnoDB,\n PARTITION p202112SUB01 VALUES LESS THAN (738493) ENGINE = InnoDB,\n PARTITION p202112SUB02 VALUES LESS THAN (738495) ENGINE = InnoDB,\n PARTITION p202112SUB03 VALUES LESS THAN (738497) ENGINE = InnoDB,\n PARTITION p202112SUB04 VALUES LESS THAN (738499) ENGINE = InnoDB,\n PARTITION p202112SUB05 VALUES LESS THAN (738501) ENGINE = InnoDB,\n PARTITION p202112SUB06 VALUES LESS THAN (738503) ENGINE = InnoDB,\n PARTITION p202112SUB07 VALUES LESS THAN (738505) ENGINE = InnoDB,\n PARTITION p202112SUB08 VALUES LESS THAN (738507) ENGINE = InnoDB,\n PARTITION p202112SUB09 VALUES LESS THAN (738509) ENGINE = InnoDB,\n PARTITION p202112SUB10 VALUES LESS THAN (738511) ENGINE = InnoDB,\n PARTITION p202112SUB11 VALUES LESS THAN (738513) ENGINE = InnoDB,\n PARTITION p202112SUB12 VALUES LESS THAN (738515) ENGINE = InnoDB,\n PARTITION p202112SUB13 VALUES LESS THAN (738517) ENGINE = InnoDB,\n PARTITION p202112SUB14 VALUES LESS THAN (738519) ENGINE = InnoDB,\n PARTITION p202201SUB00 VALUES LESS THAN (738522) ENGINE = InnoDB,\n PARTITION p202201SUB01 VALUES LESS THAN (738524) ENGINE = InnoDB,\n PARTITION p202201SUB02 VALUES LESS THAN (738526) ENGINE = InnoDB,\n PARTITION p202201SUB03 VALUES LESS THAN (738528) ENGINE = InnoDB,\n PARTITION p202201SUB04 VALUES LESS THAN (738530) ENGINE = InnoDB,\n PARTITION p202201SUB05 VALUES LESS THAN (738532) ENGINE = InnoDB,\n PARTITION p202201SUB06 VALUES LESS THAN (738534) ENGINE = InnoDB,\n PARTITION p202201SUB07 VALUES LESS THAN (738536) ENGINE = InnoDB,\n PARTITION p202201SUB08 VALUES LESS THAN (738538) ENGINE = InnoDB,\n PARTITION p202201SUB09 VALUES LESS THAN (738540) ENGINE = InnoDB,\n PARTITION p202201SUB10 VALUES LESS THAN (738542) ENGINE = InnoDB,\n PARTITION p202201SUB11 VALUES LESS THAN (738544) ENGINE = InnoDB,\n PARTITION p202201SUB12 VALUES LESS THAN (738546) ENGINE = InnoDB,\n PARTITION p202201SUB13 VALUES LESS THAN (738548) ENGINE = InnoDB,\n PARTITION p202201SUB14 VALUES LESS THAN (738550) ENGINE = InnoDB,\n PARTITION p202202SUB00 VALUES LESS THAN (738553) ENGINE = InnoDB,\n PARTITION p202202SUB01 VALUES LESS THAN (738555) ENGINE = InnoDB,\n PARTITION p202202SUB02 VALUES LESS THAN (738557) ENGINE = InnoDB,\n PARTITION p202202SUB03 VALUES LESS THAN (738559) ENGINE = InnoDB,\n PARTITION p202202SUB04 VALUES LESS THAN (738561) ENGINE = InnoDB,\n PARTITION p202202SUB05 VALUES LESS THAN (738563) ENGINE = InnoDB,\n PARTITION p202202SUB06 VALUES LESS THAN (738565) ENGINE = InnoDB,\n PARTITION p202202SUB07 VALUES LESS THAN (738567) ENGINE = InnoDB,\n PARTITION p202202SUB08 VALUES LESS THAN (738569) ENGINE = InnoDB,\n PARTITION p202202SUB09 VALUES LESS THAN (738571) ENGINE = InnoDB,\n PARTITION p202202SUB10 VALUES LESS THAN (738573) ENGINE = InnoDB,\n PARTITION p202202SUB11 VALUES LESS THAN (738575) ENGINE = InnoDB,\n PARTITION p202202SUB12 VALUES LESS THAN (738577) ENGINE = InnoDB,\n PARTITION p202202SUB13 VALUES LESS THAN (738579) ENGINE = InnoDB,\n PARTITION p202203SUB00 VALUES LESS THAN (738581) ENGINE = InnoDB,\n PARTITION p202203SUB01 VALUES LESS THAN (738583) ENGINE = InnoDB,\n PARTITION p202203SUB02 VALUES LESS THAN (738585) ENGINE = InnoDB,\n PARTITION p202203SUB03 VALUES LESS THAN (738587) ENGINE = InnoDB,\n PARTITION p202203SUB04 VALUES LESS THAN (738589) ENGINE = InnoDB,\n PARTITION p202203SUB05 VALUES LESS THAN (738591) ENGINE = InnoDB,\n PARTITION p202203SUB06 VALUES LESS THAN (738593) ENGINE = InnoDB,\n PARTITION p202203SUB07 VALUES LESS THAN (738595) ENGINE = InnoDB,\n PARTITION p202203SUB08 VALUES LESS THAN (738597) ENGINE = InnoDB,\n PARTITION p202203SUB09 VALUES LESS THAN (738599) ENGINE = InnoDB,\n PARTITION p202203SUB10 VALUES LESS THAN (738601) ENGINE = InnoDB,\n PARTITION p202203SUB11 VALUES LESS THAN (738603) ENGINE = InnoDB,\n PARTITION p202203SUB12 VALUES LESS THAN (738605) ENGINE = InnoDB,\n PARTITION p202203SUB13 VALUES LESS THAN (738607) ENGINE = InnoDB,\n PARTITION p202203SUB14 VALUES LESS THAN (738609) ENGINE = InnoDB,\n PARTITION p202204SUB00 VALUES LESS THAN (738612) ENGINE = InnoDB,\n PARTITION p202204SUB01 VALUES LESS THAN (738614) ENGINE = InnoDB,\n PARTITION p202204SUB02 VALUES LESS THAN (738616) ENGINE = InnoDB,\n PARTITION p202204SUB03 VALUES LESS THAN (738618) ENGINE = InnoDB,\n PARTITION p202204SUB04 VALUES LESS THAN (738620) ENGINE = InnoDB,\n PARTITION p202204SUB05 VALUES LESS THAN (738622) ENGINE = InnoDB,\n PARTITION p202204SUB06 VALUES LESS THAN (738624) ENGINE = InnoDB,\n PARTITION p202204SUB07 VALUES LESS THAN (738626) ENGINE = InnoDB,\n PARTITION p202204SUB08 VALUES LESS THAN (738628) ENGINE = InnoDB,\n PARTITION p202204SUB09 VALUES LESS THAN (738630) ENGINE = InnoDB,\n PARTITION p202204SUB10 VALUES LESS THAN (738632) ENGINE = InnoDB,\n PARTITION p202204SUB11 VALUES LESS THAN (738634) ENGINE = InnoDB,\n PARTITION p202204SUB12 VALUES LESS THAN (738636) ENGINE = InnoDB,\n PARTITION p202204SUB13 VALUES LESS THAN (738638) ENGINE = InnoDB,\n PARTITION p202204SUB14 VALUES LESS THAN (738640) ENGINE = InnoDB,\n PARTITION p202205SUB00 VALUES LESS THAN (738642) ENGINE = InnoDB,\n PARTITION p202205SUB01 VALUES LESS THAN (738644) ENGINE = InnoDB,\n PARTITION p202205SUB02 VALUES LESS THAN (738646) ENGINE = InnoDB,\n PARTITION p202205SUB03 VALUES LESS THAN (738648) ENGINE = InnoDB,\n PARTITION p202205SUB04 VALUES LESS THAN (738650) ENGINE = InnoDB,\n PARTITION p202205SUB05 VALUES LESS THAN (738652) ENGINE = InnoDB,\n PARTITION p202205SUB06 VALUES LESS THAN (738654) ENGINE = InnoDB,\n PARTITION p202205SUB07 VALUES LESS THAN (738656) ENGINE = InnoDB,\n PARTITION p202205SUB08 VALUES LESS THAN (738658) ENGINE = InnoDB,\n PARTITION p202205SUB09 VALUES LESS THAN (738660) ENGINE = InnoDB,\n PARTITION p202205SUB10 VALUES LESS THAN (738662) ENGINE = InnoDB,\n PARTITION p202205SUB11 VALUES LESS THAN (738664) ENGINE = InnoDB,\n PARTITION p202205SUB12 VALUES LESS THAN (738666) ENGINE = InnoDB,\n PARTITION p202205SUB13 VALUES LESS THAN (738668) ENGINE = InnoDB,\n PARTITION p202205SUB14 VALUES LESS THAN (738670) ENGINE = InnoDB,\n PARTITION p202206SUB00 VALUES LESS THAN (738673) ENGINE = InnoDB,\n PARTITION p202206SUB01 VALUES LESS THAN (738675) ENGINE = InnoDB,\n PARTITION p202206SUB02 VALUES LESS THAN (738677) ENGINE = InnoDB,\n PARTITION p202206SUB03 VALUES LESS THAN (738679) ENGINE = InnoDB,\n PARTITION p202206SUB04 VALUES LESS THAN (738681) ENGINE = InnoDB,\n PARTITION p202206SUB05 VALUES LESS THAN (738683) ENGINE = InnoDB,\n PARTITION p202206SUB06 VALUES LESS THAN (738685) ENGINE = InnoDB,\n PARTITION p202206SUB07 VALUES LESS THAN (738687) ENGINE = InnoDB,\n PARTITION p202206SUB08 VALUES LESS THAN (738689) ENGINE = InnoDB,\n PARTITION p202206SUB09 VALUES LESS THAN (738691) ENGINE = InnoDB,\n PARTITION p202206SUB10 VALUES LESS THAN (738693) ENGINE = InnoDB,\n PARTITION p202206SUB11 VALUES LESS THAN (738695) ENGINE = InnoDB,\n PARTITION p202206SUB12 VALUES LESS THAN (738697) ENGINE = InnoDB,\n PARTITION p202206SUB13 VALUES LESS THAN (738699) ENGINE = InnoDB,\n PARTITION p202206SUB14 VALUES LESS THAN (738701) ENGINE = InnoDB,\n PARTITION p202207SUB00 VALUES LESS THAN (738703) ENGINE = InnoDB,\n PARTITION p202207SUB01 VALUES LESS THAN (738705) ENGINE = InnoDB,\n PARTITION p202207SUB02 VALUES LESS THAN (738707) ENGINE = InnoDB,\n PARTITION p202207SUB03 VALUES LESS THAN (738709) ENGINE = InnoDB,\n PARTITION p202207SUB04 VALUES LESS THAN (738711) ENGINE = InnoDB,\n PARTITION p202207SUB05 VALUES LESS THAN (738713) ENGINE = InnoDB,\n PARTITION p202207SUB06 VALUES LESS THAN (738715) ENGINE = InnoDB,\n PARTITION p202207SUB07 VALUES LESS THAN (738717) ENGINE = InnoDB,\n PARTITION p202207SUB08 VALUES LESS THAN (738719) ENGINE = InnoDB,\n PARTITION p202207SUB09 VALUES LESS THAN (738721) ENGINE = InnoDB,\n PARTITION p202207SUB10 VALUES LESS THAN (738723) ENGINE = InnoDB,\n PARTITION p202207SUB11 VALUES LESS THAN (738725) ENGINE = InnoDB,\n PARTITION p202207SUB12 VALUES LESS THAN (738727) ENGINE = InnoDB,\n PARTITION p202207SUB13 VALUES LESS THAN (738729) ENGINE = InnoDB,\n PARTITION p202207SUB14 VALUES LESS THAN (738731) ENGINE = InnoDB,\n PARTITION p202208SUB00 VALUES LESS THAN (738734) ENGINE = InnoDB,\n PARTITION p202208SUB01 VALUES LESS THAN (738736) ENGINE = InnoDB,\n PARTITION p202208SUB02 VALUES LESS THAN (738738) ENGINE = InnoDB,\n PARTITION p202208SUB03 VALUES LESS THAN (738740) ENGINE = InnoDB,\n PARTITION p202208SUB04 VALUES LESS THAN (738742) ENGINE = InnoDB,\n PARTITION p202208SUB05 VALUES LESS THAN (738744) ENGINE = InnoDB,\n PARTITION p202208SUB06 VALUES LESS THAN (738746) ENGINE = InnoDB,\n PARTITION p202208SUB07 VALUES LESS THAN (738748) ENGINE = InnoDB,\n PARTITION p202208SUB08 VALUES LESS THAN (738750) ENGINE = InnoDB,\n PARTITION p202208SUB09 VALUES LESS THAN (738752) ENGINE = InnoDB,\n PARTITION p202208SUB10 VALUES LESS THAN (738754) ENGINE = InnoDB,\n PARTITION p202208SUB11 VALUES LESS THAN (738756) ENGINE = InnoDB,\n PARTITION p202208SUB12 VALUES LESS THAN (738758) ENGINE = InnoDB,\n PARTITION p202208SUB13 VALUES LESS THAN (738760) ENGINE = InnoDB,\n PARTITION p202208SUB14 VALUES LESS THAN (738762) ENGINE = InnoDB,\n PARTITION p202209SUB00 VALUES LESS THAN (738765) ENGINE = InnoDB,\n PARTITION p202209SUB01 VALUES LESS THAN (738767) ENGINE = InnoDB,\n PARTITION p202209SUB02 VALUES LESS THAN (738769) ENGINE = InnoDB,\n PARTITION p202209SUB03 VALUES LESS THAN (738771) ENGINE = InnoDB,\n PARTITION p202209SUB04 VALUES LESS THAN (738773) ENGINE = InnoDB,\n PARTITION p202209SUB05 VALUES LESS THAN (738775) ENGINE = InnoDB,\n PARTITION p202209SUB06 VALUES LESS THAN (738777) ENGINE = InnoDB,\n PARTITION p202209SUB07 VALUES LESS THAN (738779) ENGINE = InnoDB,\n PARTITION p202209SUB08 VALUES LESS THAN (738781) ENGINE = InnoDB,\n PARTITION p202209SUB09 VALUES LESS THAN (738783) ENGINE = InnoDB,\n PARTITION p202209SUB10 VALUES LESS THAN (738785) ENGINE = InnoDB,\n PARTITION p202209SUB11 VALUES LESS THAN (738787) ENGINE = InnoDB,\n PARTITION p202209SUB12 VALUES LESS THAN (738789) ENGINE = InnoDB,\n PARTITION p202209SUB13 VALUES LESS THAN (738791) ENGINE = InnoDB,\n PARTITION p202209SUB14 VALUES LESS THAN (738793) ENGINE = InnoDB,\n PARTITION p202210SUB00 VALUES LESS THAN (738795) ENGINE = InnoDB,\n PARTITION p202210SUB01 VALUES LESS THAN (738797) ENGINE = InnoDB,\n PARTITION p202210SUB02 VALUES LESS THAN (738799) ENGINE = InnoDB,\n PARTITION p202210SUB03 VALUES LESS THAN (738801) ENGINE = InnoDB,\n PARTITION p202210SUB04 VALUES LESS THAN (738803) ENGINE = InnoDB,\n PARTITION p202210SUB05 VALUES LESS THAN (738805) ENGINE = InnoDB,\n PARTITION p202210SUB06 VALUES LESS THAN (738807) ENGINE = InnoDB,\n PARTITION p202210SUB07 VALUES LESS THAN (738809) ENGINE = InnoDB,\n PARTITION p202210SUB08 VALUES LESS THAN (738811) ENGINE = InnoDB,\n PARTITION p202210SUB09 VALUES LESS THAN (738813) ENGINE = InnoDB,\n PARTITION p202210SUB10 VALUES LESS THAN (738815) ENGINE = InnoDB,\n PARTITION p202210SUB11 VALUES LESS THAN (738817) ENGINE = InnoDB,\n PARTITION p202210SUB12 VALUES LESS THAN (738819) ENGINE = InnoDB,\n PARTITION p202210SUB13 VALUES LESS THAN (738821) ENGINE = InnoDB,\n PARTITION p202210SUB14 VALUES LESS THAN (738823) ENGINE = InnoDB,\n PARTITION p202211SUB00 VALUES LESS THAN (738826) ENGINE = InnoDB,\n PARTITION p202211SUB01 VALUES LESS THAN (738828) ENGINE = InnoDB,\n PARTITION p202211SUB02 VALUES LESS THAN (738830) ENGINE = InnoDB,\n PARTITION p202211SUB03 VALUES LESS THAN (738832) ENGINE = InnoDB,\n PARTITION p202211SUB04 VALUES LESS THAN (738834) ENGINE = InnoDB,\n PARTITION p202211SUB05 VALUES LESS THAN (738836) ENGINE = InnoDB,\n PARTITION p202211SUB06 VALUES LESS THAN (738838) ENGINE = InnoDB,\n PARTITION p202211SUB07 VALUES LESS THAN (738840) ENGINE = InnoDB,\n PARTITION p202211SUB08 VALUES LESS THAN (738842) ENGINE = InnoDB,\n PARTITION p202211SUB09 VALUES LESS THAN (738844) ENGINE = InnoDB,\n PARTITION p202211SUB10 VALUES LESS THAN (738846) ENGINE = InnoDB,\n PARTITION p202211SUB11 VALUES LESS THAN (738848) ENGINE = InnoDB,\n PARTITION p202211SUB12 VALUES LESS THAN (738850) ENGINE = InnoDB,\n PARTITION p202211SUB13 VALUES LESS THAN (738852) ENGINE = InnoDB,\n PARTITION p202211SUB14 VALUES LESS THAN (738854) ENGINE = InnoDB,\n PARTITION p202212SUB00 VALUES LESS THAN (738856) ENGINE = InnoDB,\n PARTITION p202212SUB01 VALUES LESS THAN (738858) ENGINE = InnoDB,\n PARTITION p202212SUB02 VALUES LESS THAN (738860) ENGINE = InnoDB,\n PARTITION p202212SUB03 VALUES LESS THAN (738862) ENGINE = InnoDB,\n PARTITION p202212SUB04 VALUES LESS THAN (738864) ENGINE = InnoDB,\n PARTITION p202212SUB05 VALUES LESS THAN (738866) ENGINE = InnoDB,\n PARTITION p202212SUB06 VALUES LESS THAN (738868) ENGINE = InnoDB,\n PARTITION p202212SUB07 VALUES LESS THAN (738870) ENGINE = InnoDB,\n PARTITION p202212SUB08 VALUES LESS THAN (738872) ENGINE = InnoDB,\n PARTITION p202212SUB09 VALUES LESS THAN (738874) ENGINE = InnoDB,\n PARTITION p202212SUB10 VALUES LESS THAN (738876) ENGINE = InnoDB,\n PARTITION p202212SUB11 VALUES LESS THAN (738878) ENGINE = InnoDB,\n PARTITION p202212SUB12 VALUES LESS THAN (738880) ENGINE = InnoDB,\n PARTITION p202212SUB13 VALUES LESS THAN (738882) ENGINE = InnoDB,\n PARTITION p202212SUB14 VALUES LESS THAN (738884) ENGINE = InnoDB) */", force: :cascade do |t|
    t.string "id", default: "", null: false, collation: "utf8_general_ci"
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "subid_1", collation: "utf8_general_ci"
    t.string "subid_2", collation: "utf8_general_ci"
    t.string "subid_3", collation: "utf8_general_ci"
    t.integer "language_id"
    t.string "http_user_agent", collation: "utf8_general_ci"
    t.string "http_referer", collation: "utf8_general_ci"
    t.string "ip_address", collation: "utf8_general_ci"
    t.integer "clicks"
    t.integer "conversions"
    t.datetime "recorded_at", default: "1970-01-01 00:00:00", null: false
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500, collation: "utf8_general_ci"
    t.string "status", collation: "utf8_general_ci"
    t.integer "image_creative_id"
    t.datetime "converted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "vtm_host", collation: "utf8_general_ci"
    t.string "vtm_page", collation: "utf8_general_ci"
    t.string "vtm_channel", collation: "utf8_general_ci"
    t.integer "mkt_site_id"
    t.integer "hits"
    t.integer "mkt_url_id"
    t.string "vtm_campaign", collation: "utf8_general_ci"
    t.string "ip_country", collation: "utf8_general_ci"
    t.string "approval", collation: "utf8_general_ci"
    t.integer "order_id"
    t.string "step_name", collation: "utf8_general_ci"
    t.string "step_label", collation: "utf8_general_ci"
    t.string "true_conv_type", collation: "utf8_general_ci"
    t.string "affiliate_conv_type", collation: "utf8_general_ci"
    t.integer "lead_id"
    t.string "s1", collation: "utf8_general_ci"
    t.string "s2", collation: "utf8_general_ci"
    t.string "s3", collation: "utf8_general_ci"
    t.string "s4", collation: "utf8_general_ci"
    t.boolean "is_bot"
    t.integer "text_creative_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.string "keyword", collation: "utf8_general_ci"
    t.integer "share_creative_id"
    t.datetime "captured_at"
    t.string "isp", collation: "utf8_general_ci"
    t.string "browser", collation: "utf8_general_ci"
    t.string "browser_version", collation: "utf8_general_ci"
    t.string "device_type", collation: "utf8_general_ci"
    t.string "device_brand", collation: "utf8_general_ci"
    t.string "device_model", collation: "utf8_general_ci"
    t.string "aff_uniq_id", collation: "utf8_general_ci"
    t.string "ios_uniq", collation: "utf8_general_ci"
    t.string "android_uniq", collation: "utf8_general_ci"
    t.string "subid_4", collation: "utf8_general_ci"
    t.string "subid_5", collation: "utf8_general_ci"
    t.string "order_number", collation: "utf8_general_ci"
    t.string "gaid", collation: "utf8_general_ci"
    t.integer "email_creative_id"
    t.decimal "qscore", precision: 10, scale: 2
    t.string "ad_slot_id", collation: "utf8_general_ci"
    t.integer "impression"
    t.datetime "published_at", default: "1970-01-01 00:00:00", null: false
    t.json "forex"
    t.string "original_currency", limit: 3
    t.string "adv_uniq_id"
    t.decimal "order_total", precision: 20, scale: 2
    t.index ["adv_uniq_id"], name: "index_affiliate_stat_published_ats_on_adv_uniq_id"
    t.index ["aff_uniq_id"], name: "index_affiliate_stat_published_ats_on_aff_uniq_id"
    t.index ["affiliate_id"], name: "index_affiliate_stat_published_ats_on_affiliate_id"
    t.index ["id"], name: "index_affiliate_stat_published_ats_on_id"
    t.index ["ip_address"], name: "index_affiliate_stat_published_ats_on_ip_address"
    t.index ["network_id"], name: "index_affiliate_stat_published_ats_on_network_id"
    t.index ["offer_id"], name: "index_affiliate_stat_published_ats_on_offer_id"
    t.index ["order_id"], name: "index_affiliate_stat_published_ats_on_order_id"
    t.index ["order_number"], name: "index_affiliate_stat_published_ats_on_order_number"
    t.index ["status"], name: "index_affiliate_stat_published_ats_on_status"
    t.index ["subid_1"], name: "index_affiliate_stat_published_ats_on_subid_1"
    t.index ["subid_2"], name: "index_affiliate_stat_published_ats_on_subid_2"
    t.index ["subid_3"], name: "index_affiliate_stat_published_ats_on_subid_3"
    t.index ["subid_4"], name: "index_affiliate_stat_published_ats_on_subid_4"
    t.index ["subid_5"], name: "index_affiliate_stat_published_ats_on_subid_5"
    t.index ["updated_at"], name: "index_affiliate_stat_published_ats_on_updated_at"
  end

  create_table "affiliate_stats", primary_key: ["recorded_at", "id"], charset: "utf8", options: "ENGINE=InnoDB\n/*!50100 PARTITION BY RANGE ( TO_DAYS(recorded_at))\n(PARTITION p201601SUB00 VALUES LESS THAN (736334) ENGINE = InnoDB,\n PARTITION p201601SUB01 VALUES LESS THAN (736339) ENGINE = InnoDB,\n PARTITION p201601SUB02 VALUES LESS THAN (736344) ENGINE = InnoDB,\n PARTITION p201601SUB03 VALUES LESS THAN (736349) ENGINE = InnoDB,\n PARTITION p201601SUB04 VALUES LESS THAN (736354) ENGINE = InnoDB,\n PARTITION p201601SUB05 VALUES LESS THAN (736360) ENGINE = InnoDB,\n PARTITION p201602SUB00 VALUES LESS THAN (736365) ENGINE = InnoDB,\n PARTITION p201602SUB01 VALUES LESS THAN (736370) ENGINE = InnoDB,\n PARTITION p201602SUB02 VALUES LESS THAN (736375) ENGINE = InnoDB,\n PARTITION p201602SUB03 VALUES LESS THAN (736380) ENGINE = InnoDB,\n PARTITION p201602SUB04 VALUES LESS THAN (736385) ENGINE = InnoDB,\n PARTITION p201602SUB05 VALUES LESS THAN (736389) ENGINE = InnoDB,\n PARTITION p201603SUB00 VALUES LESS THAN (736394) ENGINE = InnoDB,\n PARTITION p201603SUB01 VALUES LESS THAN (736399) ENGINE = InnoDB,\n PARTITION p201603SUB02 VALUES LESS THAN (736404) ENGINE = InnoDB,\n PARTITION p201603SUB03 VALUES LESS THAN (736409) ENGINE = InnoDB,\n PARTITION p201603SUB04 VALUES LESS THAN (736414) ENGINE = InnoDB,\n PARTITION p201603SUB05 VALUES LESS THAN (736420) ENGINE = InnoDB,\n PARTITION p201604SUB00 VALUES LESS THAN (736425) ENGINE = InnoDB,\n PARTITION p201604SUB01 VALUES LESS THAN (736430) ENGINE = InnoDB,\n PARTITION p201604SUB02 VALUES LESS THAN (736435) ENGINE = InnoDB,\n PARTITION p201604SUB03 VALUES LESS THAN (736440) ENGINE = InnoDB,\n PARTITION p201604SUB04 VALUES LESS THAN (736445) ENGINE = InnoDB,\n PARTITION p201604SUB05 VALUES LESS THAN (736450) ENGINE = InnoDB,\n PARTITION p201605SUB00 VALUES LESS THAN (736455) ENGINE = InnoDB,\n PARTITION p201605SUB01 VALUES LESS THAN (736460) ENGINE = InnoDB,\n PARTITION p201605SUB02 VALUES LESS THAN (736465) ENGINE = InnoDB,\n PARTITION p201605SUB03 VALUES LESS THAN (736470) ENGINE = InnoDB,\n PARTITION p201605SUB04 VALUES LESS THAN (736475) ENGINE = InnoDB,\n PARTITION p201605SUB05 VALUES LESS THAN (736481) ENGINE = InnoDB,\n PARTITION p201606SUB00 VALUES LESS THAN (736486) ENGINE = InnoDB,\n PARTITION p201606SUB01 VALUES LESS THAN (736491) ENGINE = InnoDB,\n PARTITION p201606SUB02 VALUES LESS THAN (736496) ENGINE = InnoDB,\n PARTITION p201606SUB03 VALUES LESS THAN (736501) ENGINE = InnoDB,\n PARTITION p201606SUB04 VALUES LESS THAN (736506) ENGINE = InnoDB,\n PARTITION p201606SUB05 VALUES LESS THAN (736511) ENGINE = InnoDB,\n PARTITION p201607SUB00 VALUES LESS THAN (736516) ENGINE = InnoDB,\n PARTITION p201607SUB01 VALUES LESS THAN (736521) ENGINE = InnoDB,\n PARTITION p201607SUB02 VALUES LESS THAN (736526) ENGINE = InnoDB,\n PARTITION p201607SUB03 VALUES LESS THAN (736531) ENGINE = InnoDB,\n PARTITION p201607SUB04 VALUES LESS THAN (736536) ENGINE = InnoDB,\n PARTITION p201607SUB05 VALUES LESS THAN (736542) ENGINE = InnoDB,\n PARTITION p201608SUB00 VALUES LESS THAN (736547) ENGINE = InnoDB,\n PARTITION p201608SUB01 VALUES LESS THAN (736552) ENGINE = InnoDB,\n PARTITION p201608SUB02 VALUES LESS THAN (736557) ENGINE = InnoDB,\n PARTITION p201608SUB03 VALUES LESS THAN (736562) ENGINE = InnoDB,\n PARTITION p201608SUB04 VALUES LESS THAN (736567) ENGINE = InnoDB,\n PARTITION p201608SUB05 VALUES LESS THAN (736573) ENGINE = InnoDB,\n PARTITION p201609SUB00 VALUES LESS THAN (736578) ENGINE = InnoDB,\n PARTITION p201609SUB01 VALUES LESS THAN (736583) ENGINE = InnoDB,\n PARTITION p201609SUB02 VALUES LESS THAN (736588) ENGINE = InnoDB,\n PARTITION p201609SUB03 VALUES LESS THAN (736593) ENGINE = InnoDB,\n PARTITION p201609SUB04 VALUES LESS THAN (736598) ENGINE = InnoDB,\n PARTITION p201609SUB05 VALUES LESS THAN (736603) ENGINE = InnoDB,\n PARTITION p201610SUB00 VALUES LESS THAN (736608) ENGINE = InnoDB,\n PARTITION p201610SUB01 VALUES LESS THAN (736613) ENGINE = InnoDB,\n PARTITION p201610SUB02 VALUES LESS THAN (736618) ENGINE = InnoDB,\n PARTITION p201610SUB03 VALUES LESS THAN (736623) ENGINE = InnoDB,\n PARTITION p201610SUB04 VALUES LESS THAN (736628) ENGINE = InnoDB,\n PARTITION p201610SUB05 VALUES LESS THAN (736634) ENGINE = InnoDB,\n PARTITION p201611SUB00 VALUES LESS THAN (736639) ENGINE = InnoDB,\n PARTITION p201611SUB01 VALUES LESS THAN (736644) ENGINE = InnoDB,\n PARTITION p201611SUB02 VALUES LESS THAN (736649) ENGINE = InnoDB,\n PARTITION p201611SUB03 VALUES LESS THAN (736654) ENGINE = InnoDB,\n PARTITION p201611SUB04 VALUES LESS THAN (736659) ENGINE = InnoDB,\n PARTITION p201611SUB05 VALUES LESS THAN (736664) ENGINE = InnoDB,\n PARTITION p201612SUB00 VALUES LESS THAN (736669) ENGINE = InnoDB,\n PARTITION p201612SUB01 VALUES LESS THAN (736674) ENGINE = InnoDB,\n PARTITION p201612SUB02 VALUES LESS THAN (736679) ENGINE = InnoDB,\n PARTITION p201612SUB03 VALUES LESS THAN (736684) ENGINE = InnoDB,\n PARTITION p201612SUB04 VALUES LESS THAN (736689) ENGINE = InnoDB,\n PARTITION p201612SUB05 VALUES LESS THAN (736695) ENGINE = InnoDB,\n PARTITION p201701SUB00 VALUES LESS THAN (736700) ENGINE = InnoDB,\n PARTITION p201701SUB01 VALUES LESS THAN (736705) ENGINE = InnoDB,\n PARTITION p201701SUB02 VALUES LESS THAN (736710) ENGINE = InnoDB,\n PARTITION p201701SUB03 VALUES LESS THAN (736715) ENGINE = InnoDB,\n PARTITION p201701SUB04 VALUES LESS THAN (736720) ENGINE = InnoDB,\n PARTITION p201701SUB05 VALUES LESS THAN (736726) ENGINE = InnoDB,\n PARTITION p201702SUB00 VALUES LESS THAN (736731) ENGINE = InnoDB,\n PARTITION p201702SUB01 VALUES LESS THAN (736736) ENGINE = InnoDB,\n PARTITION p201702SUB02 VALUES LESS THAN (736741) ENGINE = InnoDB,\n PARTITION p201702SUB03 VALUES LESS THAN (736746) ENGINE = InnoDB,\n PARTITION p201702SUB04 VALUES LESS THAN (736751) ENGINE = InnoDB,\n PARTITION p201702SUB05 VALUES LESS THAN (736754) ENGINE = InnoDB,\n PARTITION p201703SUB00 VALUES LESS THAN (736759) ENGINE = InnoDB,\n PARTITION p201703SUB01 VALUES LESS THAN (736764) ENGINE = InnoDB,\n PARTITION p201703SUB02 VALUES LESS THAN (736769) ENGINE = InnoDB,\n PARTITION p201703SUB03 VALUES LESS THAN (736774) ENGINE = InnoDB,\n PARTITION p201703SUB04 VALUES LESS THAN (736779) ENGINE = InnoDB,\n PARTITION p201703SUB05 VALUES LESS THAN (736785) ENGINE = InnoDB,\n PARTITION p201704SUB00 VALUES LESS THAN (736790) ENGINE = InnoDB,\n PARTITION p201704SUB01 VALUES LESS THAN (736795) ENGINE = InnoDB,\n PARTITION p201704SUB02 VALUES LESS THAN (736800) ENGINE = InnoDB,\n PARTITION p201704SUB03 VALUES LESS THAN (736805) ENGINE = InnoDB,\n PARTITION p201704SUB04 VALUES LESS THAN (736810) ENGINE = InnoDB,\n PARTITION p201704SUB05 VALUES LESS THAN (736815) ENGINE = InnoDB,\n PARTITION p201705SUB00 VALUES LESS THAN (736820) ENGINE = InnoDB,\n PARTITION p201705SUB01 VALUES LESS THAN (736825) ENGINE = InnoDB,\n PARTITION p201705SUB02 VALUES LESS THAN (736830) ENGINE = InnoDB,\n PARTITION p201705SUB03 VALUES LESS THAN (736835) ENGINE = InnoDB,\n PARTITION p201705SUB04 VALUES LESS THAN (736840) ENGINE = InnoDB,\n PARTITION p201705SUB05 VALUES LESS THAN (736846) ENGINE = InnoDB,\n PARTITION p201706SUB00 VALUES LESS THAN (736851) ENGINE = InnoDB,\n PARTITION p201706SUB01 VALUES LESS THAN (736856) ENGINE = InnoDB,\n PARTITION p201706SUB02 VALUES LESS THAN (736861) ENGINE = InnoDB,\n PARTITION p201706SUB03 VALUES LESS THAN (736866) ENGINE = InnoDB,\n PARTITION p201706SUB04 VALUES LESS THAN (736871) ENGINE = InnoDB,\n PARTITION p201706SUB05 VALUES LESS THAN (736876) ENGINE = InnoDB,\n PARTITION p201707SUB00 VALUES LESS THAN (736881) ENGINE = InnoDB,\n PARTITION p201707SUB01 VALUES LESS THAN (736886) ENGINE = InnoDB,\n PARTITION p201707SUB02 VALUES LESS THAN (736891) ENGINE = InnoDB,\n PARTITION p201707SUB03 VALUES LESS THAN (736896) ENGINE = InnoDB,\n PARTITION p201707SUB04 VALUES LESS THAN (736901) ENGINE = InnoDB,\n PARTITION p201707SUB05 VALUES LESS THAN (736907) ENGINE = InnoDB,\n PARTITION p201708SUB00 VALUES LESS THAN (736912) ENGINE = InnoDB,\n PARTITION p201708SUB01 VALUES LESS THAN (736917) ENGINE = InnoDB,\n PARTITION p201708SUB02 VALUES LESS THAN (736922) ENGINE = InnoDB,\n PARTITION p201708SUB03 VALUES LESS THAN (736927) ENGINE = InnoDB,\n PARTITION p201708SUB04 VALUES LESS THAN (736932) ENGINE = InnoDB,\n PARTITION p201708SUB05 VALUES LESS THAN (736938) ENGINE = InnoDB,\n PARTITION p201709SUB00 VALUES LESS THAN (736943) ENGINE = InnoDB,\n PARTITION p201709SUB01 VALUES LESS THAN (736948) ENGINE = InnoDB,\n PARTITION p201709SUB02 VALUES LESS THAN (736953) ENGINE = InnoDB,\n PARTITION p201709SUB03 VALUES LESS THAN (736958) ENGINE = InnoDB,\n PARTITION p201709SUB04 VALUES LESS THAN (736963) ENGINE = InnoDB,\n PARTITION p201709SUB05 VALUES LESS THAN (736968) ENGINE = InnoDB,\n PARTITION p201710SUB00 VALUES LESS THAN (736973) ENGINE = InnoDB,\n PARTITION p201710SUB01 VALUES LESS THAN (736978) ENGINE = InnoDB,\n PARTITION p201710SUB02 VALUES LESS THAN (736983) ENGINE = InnoDB,\n PARTITION p201710SUB03 VALUES LESS THAN (736988) ENGINE = InnoDB,\n PARTITION p201710SUB04 VALUES LESS THAN (736993) ENGINE = InnoDB,\n PARTITION p201710SUB05 VALUES LESS THAN (736999) ENGINE = InnoDB,\n PARTITION p201711SUB00 VALUES LESS THAN (737004) ENGINE = InnoDB,\n PARTITION p201711SUB01 VALUES LESS THAN (737009) ENGINE = InnoDB,\n PARTITION p201711SUB02 VALUES LESS THAN (737014) ENGINE = InnoDB,\n PARTITION p201711SUB03 VALUES LESS THAN (737019) ENGINE = InnoDB,\n PARTITION p201711SUB04 VALUES LESS THAN (737024) ENGINE = InnoDB,\n PARTITION p201711SUB05 VALUES LESS THAN (737029) ENGINE = InnoDB,\n PARTITION p201712SUB00 VALUES LESS THAN (737034) ENGINE = InnoDB,\n PARTITION p201712SUB01 VALUES LESS THAN (737039) ENGINE = InnoDB,\n PARTITION p201712SUB02 VALUES LESS THAN (737044) ENGINE = InnoDB,\n PARTITION p201712SUB03 VALUES LESS THAN (737049) ENGINE = InnoDB,\n PARTITION p201712SUB04 VALUES LESS THAN (737054) ENGINE = InnoDB,\n PARTITION p201712SUB05 VALUES LESS THAN (737060) ENGINE = InnoDB,\n PARTITION p201801SUB00 VALUES LESS THAN (737061) ENGINE = InnoDB,\n PARTITION p201801SUB01 VALUES LESS THAN (737063) ENGINE = InnoDB,\n PARTITION p201801SUB02 VALUES LESS THAN (737065) ENGINE = InnoDB,\n PARTITION p201801SUB03 VALUES LESS THAN (737067) ENGINE = InnoDB,\n PARTITION p201801SUB04 VALUES LESS THAN (737069) ENGINE = InnoDB,\n PARTITION p201801SUB05 VALUES LESS THAN (737071) ENGINE = InnoDB,\n PARTITION p201801SUB06 VALUES LESS THAN (737073) ENGINE = InnoDB,\n PARTITION p201801SUB07 VALUES LESS THAN (737075) ENGINE = InnoDB,\n PARTITION p201801SUB08 VALUES LESS THAN (737077) ENGINE = InnoDB,\n PARTITION p201801SUB09 VALUES LESS THAN (737079) ENGINE = InnoDB,\n PARTITION p201801SUB10 VALUES LESS THAN (737081) ENGINE = InnoDB,\n PARTITION p201801SUB11 VALUES LESS THAN (737083) ENGINE = InnoDB,\n PARTITION p201801SUB12 VALUES LESS THAN (737085) ENGINE = InnoDB,\n PARTITION p201801SUB13 VALUES LESS THAN (737087) ENGINE = InnoDB,\n PARTITION p201801SUB14 VALUES LESS THAN (737089) ENGINE = InnoDB,\n PARTITION p201802SUB00 VALUES LESS THAN (737092) ENGINE = InnoDB,\n PARTITION p201802SUB01 VALUES LESS THAN (737094) ENGINE = InnoDB,\n PARTITION p201802SUB02 VALUES LESS THAN (737096) ENGINE = InnoDB,\n PARTITION p201802SUB03 VALUES LESS THAN (737098) ENGINE = InnoDB,\n PARTITION p201802SUB04 VALUES LESS THAN (737100) ENGINE = InnoDB,\n PARTITION p201802SUB05 VALUES LESS THAN (737102) ENGINE = InnoDB,\n PARTITION p201802SUB06 VALUES LESS THAN (737104) ENGINE = InnoDB,\n PARTITION p201802SUB07 VALUES LESS THAN (737106) ENGINE = InnoDB,\n PARTITION p201802SUB08 VALUES LESS THAN (737108) ENGINE = InnoDB,\n PARTITION p201802SUB09 VALUES LESS THAN (737110) ENGINE = InnoDB,\n PARTITION p201802SUB10 VALUES LESS THAN (737112) ENGINE = InnoDB,\n PARTITION p201802SUB11 VALUES LESS THAN (737114) ENGINE = InnoDB,\n PARTITION p201802SUB12 VALUES LESS THAN (737116) ENGINE = InnoDB,\n PARTITION p201802SUB13 VALUES LESS THAN (737118) ENGINE = InnoDB,\n PARTITION p201803SUB00 VALUES LESS THAN (737120) ENGINE = InnoDB,\n PARTITION p201803SUB01 VALUES LESS THAN (737122) ENGINE = InnoDB,\n PARTITION p201803SUB02 VALUES LESS THAN (737124) ENGINE = InnoDB,\n PARTITION p201803SUB03 VALUES LESS THAN (737126) ENGINE = InnoDB,\n PARTITION p201803SUB04 VALUES LESS THAN (737128) ENGINE = InnoDB,\n PARTITION p201803SUB05 VALUES LESS THAN (737130) ENGINE = InnoDB,\n PARTITION p201803SUB06 VALUES LESS THAN (737132) ENGINE = InnoDB,\n PARTITION p201803SUB07 VALUES LESS THAN (737134) ENGINE = InnoDB,\n PARTITION p201803SUB08 VALUES LESS THAN (737136) ENGINE = InnoDB,\n PARTITION p201803SUB09 VALUES LESS THAN (737138) ENGINE = InnoDB,\n PARTITION p201803SUB10 VALUES LESS THAN (737140) ENGINE = InnoDB,\n PARTITION p201803SUB11 VALUES LESS THAN (737142) ENGINE = InnoDB,\n PARTITION p201803SUB12 VALUES LESS THAN (737144) ENGINE = InnoDB,\n PARTITION p201803SUB13 VALUES LESS THAN (737146) ENGINE = InnoDB,\n PARTITION p201803SUB14 VALUES LESS THAN (737148) ENGINE = InnoDB,\n PARTITION p201804SUB00 VALUES LESS THAN (737151) ENGINE = InnoDB,\n PARTITION p201804SUB01 VALUES LESS THAN (737153) ENGINE = InnoDB,\n PARTITION p201804SUB02 VALUES LESS THAN (737155) ENGINE = InnoDB,\n PARTITION p201804SUB03 VALUES LESS THAN (737157) ENGINE = InnoDB,\n PARTITION p201804SUB04 VALUES LESS THAN (737159) ENGINE = InnoDB,\n PARTITION p201804SUB05 VALUES LESS THAN (737161) ENGINE = InnoDB,\n PARTITION p201804SUB06 VALUES LESS THAN (737163) ENGINE = InnoDB,\n PARTITION p201804SUB07 VALUES LESS THAN (737165) ENGINE = InnoDB,\n PARTITION p201804SUB08 VALUES LESS THAN (737167) ENGINE = InnoDB,\n PARTITION p201804SUB09 VALUES LESS THAN (737169) ENGINE = InnoDB,\n PARTITION p201804SUB10 VALUES LESS THAN (737171) ENGINE = InnoDB,\n PARTITION p201804SUB11 VALUES LESS THAN (737173) ENGINE = InnoDB,\n PARTITION p201804SUB12 VALUES LESS THAN (737175) ENGINE = InnoDB,\n PARTITION p201804SUB13 VALUES LESS THAN (737177) ENGINE = InnoDB,\n PARTITION p201804SUB14 VALUES LESS THAN (737179) ENGINE = InnoDB,\n PARTITION p201805SUB00 VALUES LESS THAN (737181) ENGINE = InnoDB,\n PARTITION p201805SUB01 VALUES LESS THAN (737183) ENGINE = InnoDB,\n PARTITION p201805SUB02 VALUES LESS THAN (737185) ENGINE = InnoDB,\n PARTITION p201805SUB03 VALUES LESS THAN (737187) ENGINE = InnoDB,\n PARTITION p201805SUB04 VALUES LESS THAN (737189) ENGINE = InnoDB,\n PARTITION p201805SUB05 VALUES LESS THAN (737191) ENGINE = InnoDB,\n PARTITION p201805SUB06 VALUES LESS THAN (737193) ENGINE = InnoDB,\n PARTITION p201805SUB07 VALUES LESS THAN (737195) ENGINE = InnoDB,\n PARTITION p201805SUB08 VALUES LESS THAN (737197) ENGINE = InnoDB,\n PARTITION p201805SUB09 VALUES LESS THAN (737199) ENGINE = InnoDB,\n PARTITION p201805SUB10 VALUES LESS THAN (737201) ENGINE = InnoDB,\n PARTITION p201805SUB11 VALUES LESS THAN (737203) ENGINE = InnoDB,\n PARTITION p201805SUB12 VALUES LESS THAN (737205) ENGINE = InnoDB,\n PARTITION p201805SUB13 VALUES LESS THAN (737207) ENGINE = InnoDB,\n PARTITION p201805SUB14 VALUES LESS THAN (737209) ENGINE = InnoDB,\n PARTITION p201806SUB00 VALUES LESS THAN (737212) ENGINE = InnoDB,\n PARTITION p201806SUB01 VALUES LESS THAN (737214) ENGINE = InnoDB,\n PARTITION p201806SUB02 VALUES LESS THAN (737216) ENGINE = InnoDB,\n PARTITION p201806SUB03 VALUES LESS THAN (737218) ENGINE = InnoDB,\n PARTITION p201806SUB04 VALUES LESS THAN (737220) ENGINE = InnoDB,\n PARTITION p201806SUB05 VALUES LESS THAN (737222) ENGINE = InnoDB,\n PARTITION p201806SUB06 VALUES LESS THAN (737224) ENGINE = InnoDB,\n PARTITION p201806SUB07 VALUES LESS THAN (737226) ENGINE = InnoDB,\n PARTITION p201806SUB08 VALUES LESS THAN (737228) ENGINE = InnoDB,\n PARTITION p201806SUB09 VALUES LESS THAN (737230) ENGINE = InnoDB,\n PARTITION p201806SUB10 VALUES LESS THAN (737232) ENGINE = InnoDB,\n PARTITION p201806SUB11 VALUES LESS THAN (737234) ENGINE = InnoDB,\n PARTITION p201806SUB12 VALUES LESS THAN (737236) ENGINE = InnoDB,\n PARTITION p201806SUB13 VALUES LESS THAN (737238) ENGINE = InnoDB,\n PARTITION p201806SUB14 VALUES LESS THAN (737240) ENGINE = InnoDB,\n PARTITION p201807SUB00 VALUES LESS THAN (737242) ENGINE = InnoDB,\n PARTITION p201807SUB01 VALUES LESS THAN (737244) ENGINE = InnoDB,\n PARTITION p201807SUB02 VALUES LESS THAN (737246) ENGINE = InnoDB,\n PARTITION p201807SUB03 VALUES LESS THAN (737248) ENGINE = InnoDB,\n PARTITION p201807SUB04 VALUES LESS THAN (737250) ENGINE = InnoDB,\n PARTITION p201807SUB05 VALUES LESS THAN (737252) ENGINE = InnoDB,\n PARTITION p201807SUB06 VALUES LESS THAN (737254) ENGINE = InnoDB,\n PARTITION p201807SUB07 VALUES LESS THAN (737256) ENGINE = InnoDB,\n PARTITION p201807SUB08 VALUES LESS THAN (737258) ENGINE = InnoDB,\n PARTITION p201807SUB09 VALUES LESS THAN (737260) ENGINE = InnoDB,\n PARTITION p201807SUB10 VALUES LESS THAN (737262) ENGINE = InnoDB,\n PARTITION p201807SUB11 VALUES LESS THAN (737264) ENGINE = InnoDB,\n PARTITION p201807SUB12 VALUES LESS THAN (737266) ENGINE = InnoDB,\n PARTITION p201807SUB13 VALUES LESS THAN (737268) ENGINE = InnoDB,\n PARTITION p201807SUB14 VALUES LESS THAN (737270) ENGINE = InnoDB,\n PARTITION p201808SUB00 VALUES LESS THAN (737273) ENGINE = InnoDB,\n PARTITION p201808SUB01 VALUES LESS THAN (737275) ENGINE = InnoDB,\n PARTITION p201808SUB02 VALUES LESS THAN (737277) ENGINE = InnoDB,\n PARTITION p201808SUB03 VALUES LESS THAN (737279) ENGINE = InnoDB,\n PARTITION p201808SUB04 VALUES LESS THAN (737281) ENGINE = InnoDB,\n PARTITION p201808SUB05 VALUES LESS THAN (737283) ENGINE = InnoDB,\n PARTITION p201808SUB06 VALUES LESS THAN (737285) ENGINE = InnoDB,\n PARTITION p201808SUB07 VALUES LESS THAN (737287) ENGINE = InnoDB,\n PARTITION p201808SUB08 VALUES LESS THAN (737289) ENGINE = InnoDB,\n PARTITION p201808SUB09 VALUES LESS THAN (737291) ENGINE = InnoDB,\n PARTITION p201808SUB10 VALUES LESS THAN (737293) ENGINE = InnoDB,\n PARTITION p201808SUB11 VALUES LESS THAN (737295) ENGINE = InnoDB,\n PARTITION p201808SUB12 VALUES LESS THAN (737297) ENGINE = InnoDB,\n PARTITION p201808SUB13 VALUES LESS THAN (737299) ENGINE = InnoDB,\n PARTITION p201808SUB14 VALUES LESS THAN (737301) ENGINE = InnoDB,\n PARTITION p201809SUB00 VALUES LESS THAN (737304) ENGINE = InnoDB,\n PARTITION p201809SUB01 VALUES LESS THAN (737306) ENGINE = InnoDB,\n PARTITION p201809SUB02 VALUES LESS THAN (737308) ENGINE = InnoDB,\n PARTITION p201809SUB03 VALUES LESS THAN (737310) ENGINE = InnoDB,\n PARTITION p201809SUB04 VALUES LESS THAN (737312) ENGINE = InnoDB,\n PARTITION p201809SUB05 VALUES LESS THAN (737314) ENGINE = InnoDB,\n PARTITION p201809SUB06 VALUES LESS THAN (737316) ENGINE = InnoDB,\n PARTITION p201809SUB07 VALUES LESS THAN (737318) ENGINE = InnoDB,\n PARTITION p201809SUB08 VALUES LESS THAN (737320) ENGINE = InnoDB,\n PARTITION p201809SUB09 VALUES LESS THAN (737322) ENGINE = InnoDB,\n PARTITION p201809SUB10 VALUES LESS THAN (737324) ENGINE = InnoDB,\n PARTITION p201809SUB11 VALUES LESS THAN (737326) ENGINE = InnoDB,\n PARTITION p201809SUB12 VALUES LESS THAN (737328) ENGINE = InnoDB,\n PARTITION p201809SUB13 VALUES LESS THAN (737330) ENGINE = InnoDB,\n PARTITION p201809SUB14 VALUES LESS THAN (737332) ENGINE = InnoDB,\n PARTITION p201810SUB00 VALUES LESS THAN (737334) ENGINE = InnoDB,\n PARTITION p201810SUB01 VALUES LESS THAN (737336) ENGINE = InnoDB,\n PARTITION p201810SUB02 VALUES LESS THAN (737338) ENGINE = InnoDB,\n PARTITION p201810SUB03 VALUES LESS THAN (737340) ENGINE = InnoDB,\n PARTITION p201810SUB04 VALUES LESS THAN (737342) ENGINE = InnoDB,\n PARTITION p201810SUB05 VALUES LESS THAN (737344) ENGINE = InnoDB,\n PARTITION p201810SUB06 VALUES LESS THAN (737346) ENGINE = InnoDB,\n PARTITION p201810SUB07 VALUES LESS THAN (737348) ENGINE = InnoDB,\n PARTITION p201810SUB08 VALUES LESS THAN (737350) ENGINE = InnoDB,\n PARTITION p201810SUB09 VALUES LESS THAN (737352) ENGINE = InnoDB,\n PARTITION p201810SUB10 VALUES LESS THAN (737354) ENGINE = InnoDB,\n PARTITION p201810SUB11 VALUES LESS THAN (737356) ENGINE = InnoDB,\n PARTITION p201810SUB12 VALUES LESS THAN (737358) ENGINE = InnoDB,\n PARTITION p201810SUB13 VALUES LESS THAN (737360) ENGINE = InnoDB,\n PARTITION p201810SUB14 VALUES LESS THAN (737362) ENGINE = InnoDB,\n PARTITION p201811SUB00 VALUES LESS THAN (737365) ENGINE = InnoDB,\n PARTITION p201811SUB01 VALUES LESS THAN (737367) ENGINE = InnoDB,\n PARTITION p201811SUB02 VALUES LESS THAN (737369) ENGINE = InnoDB,\n PARTITION p201811SUB03 VALUES LESS THAN (737371) ENGINE = InnoDB,\n PARTITION p201811SUB04 VALUES LESS THAN (737373) ENGINE = InnoDB,\n PARTITION p201811SUB05 VALUES LESS THAN (737375) ENGINE = InnoDB,\n PARTITION p201811SUB06 VALUES LESS THAN (737377) ENGINE = InnoDB,\n PARTITION p201811SUB07 VALUES LESS THAN (737379) ENGINE = InnoDB,\n PARTITION p201811SUB08 VALUES LESS THAN (737381) ENGINE = InnoDB,\n PARTITION p201811SUB09 VALUES LESS THAN (737383) ENGINE = InnoDB,\n PARTITION p201811SUB10 VALUES LESS THAN (737385) ENGINE = InnoDB,\n PARTITION p201811SUB11 VALUES LESS THAN (737387) ENGINE = InnoDB,\n PARTITION p201811SUB12 VALUES LESS THAN (737389) ENGINE = InnoDB,\n PARTITION p201811SUB13 VALUES LESS THAN (737391) ENGINE = InnoDB,\n PARTITION p201811SUB14 VALUES LESS THAN (737393) ENGINE = InnoDB,\n PARTITION p201812SUB00 VALUES LESS THAN (737395) ENGINE = InnoDB,\n PARTITION p201812SUB01 VALUES LESS THAN (737397) ENGINE = InnoDB,\n PARTITION p201812SUB02 VALUES LESS THAN (737399) ENGINE = InnoDB,\n PARTITION p201812SUB03 VALUES LESS THAN (737401) ENGINE = InnoDB,\n PARTITION p201812SUB04 VALUES LESS THAN (737403) ENGINE = InnoDB,\n PARTITION p201812SUB05 VALUES LESS THAN (737405) ENGINE = InnoDB,\n PARTITION p201812SUB06 VALUES LESS THAN (737407) ENGINE = InnoDB,\n PARTITION p201812SUB07 VALUES LESS THAN (737409) ENGINE = InnoDB,\n PARTITION p201812SUB08 VALUES LESS THAN (737411) ENGINE = InnoDB,\n PARTITION p201812SUB09 VALUES LESS THAN (737413) ENGINE = InnoDB,\n PARTITION p201812SUB10 VALUES LESS THAN (737415) ENGINE = InnoDB,\n PARTITION p201812SUB11 VALUES LESS THAN (737417) ENGINE = InnoDB,\n PARTITION p201812SUB12 VALUES LESS THAN (737419) ENGINE = InnoDB,\n PARTITION p201812SUB13 VALUES LESS THAN (737421) ENGINE = InnoDB,\n PARTITION p201812SUB14 VALUES LESS THAN (737423) ENGINE = InnoDB,\n PARTITION p201901SUB00 VALUES LESS THAN (737426) ENGINE = InnoDB,\n PARTITION p201901SUB01 VALUES LESS THAN (737428) ENGINE = InnoDB,\n PARTITION p201901SUB02 VALUES LESS THAN (737430) ENGINE = InnoDB,\n PARTITION p201901SUB03 VALUES LESS THAN (737432) ENGINE = InnoDB,\n PARTITION p201901SUB04 VALUES LESS THAN (737434) ENGINE = InnoDB,\n PARTITION p201901SUB05 VALUES LESS THAN (737436) ENGINE = InnoDB,\n PARTITION p201901SUB06 VALUES LESS THAN (737438) ENGINE = InnoDB,\n PARTITION p201901SUB07 VALUES LESS THAN (737440) ENGINE = InnoDB,\n PARTITION p201901SUB08 VALUES LESS THAN (737442) ENGINE = InnoDB,\n PARTITION p201901SUB09 VALUES LESS THAN (737444) ENGINE = InnoDB,\n PARTITION p201901SUB10 VALUES LESS THAN (737446) ENGINE = InnoDB,\n PARTITION p201901SUB11 VALUES LESS THAN (737448) ENGINE = InnoDB,\n PARTITION p201901SUB12 VALUES LESS THAN (737450) ENGINE = InnoDB,\n PARTITION p201901SUB13 VALUES LESS THAN (737452) ENGINE = InnoDB,\n PARTITION p201901SUB14 VALUES LESS THAN (737454) ENGINE = InnoDB,\n PARTITION p201902SUB00 VALUES LESS THAN (737457) ENGINE = InnoDB,\n PARTITION p201902SUB01 VALUES LESS THAN (737459) ENGINE = InnoDB,\n PARTITION p201902SUB02 VALUES LESS THAN (737461) ENGINE = InnoDB,\n PARTITION p201902SUB03 VALUES LESS THAN (737463) ENGINE = InnoDB,\n PARTITION p201902SUB04 VALUES LESS THAN (737465) ENGINE = InnoDB,\n PARTITION p201902SUB05 VALUES LESS THAN (737467) ENGINE = InnoDB,\n PARTITION p201902SUB06 VALUES LESS THAN (737469) ENGINE = InnoDB,\n PARTITION p201902SUB07 VALUES LESS THAN (737471) ENGINE = InnoDB,\n PARTITION p201902SUB08 VALUES LESS THAN (737473) ENGINE = InnoDB,\n PARTITION p201902SUB09 VALUES LESS THAN (737475) ENGINE = InnoDB,\n PARTITION p201902SUB10 VALUES LESS THAN (737477) ENGINE = InnoDB,\n PARTITION p201902SUB11 VALUES LESS THAN (737479) ENGINE = InnoDB,\n PARTITION p201902SUB12 VALUES LESS THAN (737481) ENGINE = InnoDB,\n PARTITION p201902SUB13 VALUES LESS THAN (737483) ENGINE = InnoDB,\n PARTITION p201903SUB00 VALUES LESS THAN (737485) ENGINE = InnoDB,\n PARTITION p201903SUB01 VALUES LESS THAN (737487) ENGINE = InnoDB,\n PARTITION p201903SUB02 VALUES LESS THAN (737489) ENGINE = InnoDB,\n PARTITION p201903SUB03 VALUES LESS THAN (737491) ENGINE = InnoDB,\n PARTITION p201903SUB04 VALUES LESS THAN (737493) ENGINE = InnoDB,\n PARTITION p201903SUB05 VALUES LESS THAN (737495) ENGINE = InnoDB,\n PARTITION p201903SUB06 VALUES LESS THAN (737497) ENGINE = InnoDB,\n PARTITION p201903SUB07 VALUES LESS THAN (737499) ENGINE = InnoDB,\n PARTITION p201903SUB08 VALUES LESS THAN (737501) ENGINE = InnoDB,\n PARTITION p201903SUB09 VALUES LESS THAN (737503) ENGINE = InnoDB,\n PARTITION p201903SUB10 VALUES LESS THAN (737505) ENGINE = InnoDB,\n PARTITION p201903SUB11 VALUES LESS THAN (737507) ENGINE = InnoDB,\n PARTITION p201903SUB12 VALUES LESS THAN (737509) ENGINE = InnoDB,\n PARTITION p201903SUB13 VALUES LESS THAN (737511) ENGINE = InnoDB,\n PARTITION p201903SUB14 VALUES LESS THAN (737513) ENGINE = InnoDB,\n PARTITION p201904SUB00 VALUES LESS THAN (737516) ENGINE = InnoDB,\n PARTITION p201904SUB01 VALUES LESS THAN (737518) ENGINE = InnoDB,\n PARTITION p201904SUB02 VALUES LESS THAN (737520) ENGINE = InnoDB,\n PARTITION p201904SUB03 VALUES LESS THAN (737522) ENGINE = InnoDB,\n PARTITION p201904SUB04 VALUES LESS THAN (737524) ENGINE = InnoDB,\n PARTITION p201904SUB05 VALUES LESS THAN (737526) ENGINE = InnoDB,\n PARTITION p201904SUB06 VALUES LESS THAN (737528) ENGINE = InnoDB,\n PARTITION p201904SUB07 VALUES LESS THAN (737530) ENGINE = InnoDB,\n PARTITION p201904SUB08 VALUES LESS THAN (737532) ENGINE = InnoDB,\n PARTITION p201904SUB09 VALUES LESS THAN (737534) ENGINE = InnoDB,\n PARTITION p201904SUB10 VALUES LESS THAN (737536) ENGINE = InnoDB,\n PARTITION p201904SUB11 VALUES LESS THAN (737538) ENGINE = InnoDB,\n PARTITION p201904SUB12 VALUES LESS THAN (737540) ENGINE = InnoDB,\n PARTITION p201904SUB13 VALUES LESS THAN (737542) ENGINE = InnoDB,\n PARTITION p201904SUB14 VALUES LESS THAN (737544) ENGINE = InnoDB,\n PARTITION p201905SUB00 VALUES LESS THAN (737546) ENGINE = InnoDB,\n PARTITION p201905SUB01 VALUES LESS THAN (737548) ENGINE = InnoDB,\n PARTITION p201905SUB02 VALUES LESS THAN (737550) ENGINE = InnoDB,\n PARTITION p201905SUB03 VALUES LESS THAN (737552) ENGINE = InnoDB,\n PARTITION p201905SUB04 VALUES LESS THAN (737554) ENGINE = InnoDB,\n PARTITION p201905SUB05 VALUES LESS THAN (737556) ENGINE = InnoDB,\n PARTITION p201905SUB06 VALUES LESS THAN (737558) ENGINE = InnoDB,\n PARTITION p201905SUB07 VALUES LESS THAN (737560) ENGINE = InnoDB,\n PARTITION p201905SUB08 VALUES LESS THAN (737562) ENGINE = InnoDB,\n PARTITION p201905SUB09 VALUES LESS THAN (737564) ENGINE = InnoDB,\n PARTITION p201905SUB10 VALUES LESS THAN (737566) ENGINE = InnoDB,\n PARTITION p201905SUB11 VALUES LESS THAN (737568) ENGINE = InnoDB,\n PARTITION p201905SUB12 VALUES LESS THAN (737570) ENGINE = InnoDB,\n PARTITION p201905SUB13 VALUES LESS THAN (737572) ENGINE = InnoDB,\n PARTITION p201905SUB14 VALUES LESS THAN (737574) ENGINE = InnoDB,\n PARTITION p201906SUB00 VALUES LESS THAN (737577) ENGINE = InnoDB,\n PARTITION p201906SUB01 VALUES LESS THAN (737579) ENGINE = InnoDB,\n PARTITION p201906SUB02 VALUES LESS THAN (737581) ENGINE = InnoDB,\n PARTITION p201906SUB03 VALUES LESS THAN (737583) ENGINE = InnoDB,\n PARTITION p201906SUB04 VALUES LESS THAN (737585) ENGINE = InnoDB,\n PARTITION p201906SUB05 VALUES LESS THAN (737587) ENGINE = InnoDB,\n PARTITION p201906SUB06 VALUES LESS THAN (737589) ENGINE = InnoDB,\n PARTITION p201906SUB07 VALUES LESS THAN (737591) ENGINE = InnoDB,\n PARTITION p201906SUB08 VALUES LESS THAN (737593) ENGINE = InnoDB,\n PARTITION p201906SUB09 VALUES LESS THAN (737595) ENGINE = InnoDB,\n PARTITION p201906SUB10 VALUES LESS THAN (737597) ENGINE = InnoDB,\n PARTITION p201906SUB11 VALUES LESS THAN (737599) ENGINE = InnoDB,\n PARTITION p201906SUB12 VALUES LESS THAN (737601) ENGINE = InnoDB,\n PARTITION p201906SUB13 VALUES LESS THAN (737603) ENGINE = InnoDB,\n PARTITION p201906SUB14 VALUES LESS THAN (737605) ENGINE = InnoDB,\n PARTITION p201907SUB00 VALUES LESS THAN (737607) ENGINE = InnoDB,\n PARTITION p201907SUB01 VALUES LESS THAN (737609) ENGINE = InnoDB,\n PARTITION p201907SUB02 VALUES LESS THAN (737611) ENGINE = InnoDB,\n PARTITION p201907SUB03 VALUES LESS THAN (737613) ENGINE = InnoDB,\n PARTITION p201907SUB04 VALUES LESS THAN (737615) ENGINE = InnoDB,\n PARTITION p201907SUB05 VALUES LESS THAN (737617) ENGINE = InnoDB,\n PARTITION p201907SUB06 VALUES LESS THAN (737619) ENGINE = InnoDB,\n PARTITION p201907SUB07 VALUES LESS THAN (737621) ENGINE = InnoDB,\n PARTITION p201907SUB08 VALUES LESS THAN (737623) ENGINE = InnoDB,\n PARTITION p201907SUB09 VALUES LESS THAN (737625) ENGINE = InnoDB,\n PARTITION p201907SUB10 VALUES LESS THAN (737627) ENGINE = InnoDB,\n PARTITION p201907SUB11 VALUES LESS THAN (737629) ENGINE = InnoDB,\n PARTITION p201907SUB12 VALUES LESS THAN (737631) ENGINE = InnoDB,\n PARTITION p201907SUB13 VALUES LESS THAN (737633) ENGINE = InnoDB,\n PARTITION p201907SUB14 VALUES LESS THAN (737635) ENGINE = InnoDB,\n PARTITION p201908SUB00 VALUES LESS THAN (737638) ENGINE = InnoDB,\n PARTITION p201908SUB01 VALUES LESS THAN (737640) ENGINE = InnoDB,\n PARTITION p201908SUB02 VALUES LESS THAN (737642) ENGINE = InnoDB,\n PARTITION p201908SUB03 VALUES LESS THAN (737644) ENGINE = InnoDB,\n PARTITION p201908SUB04 VALUES LESS THAN (737646) ENGINE = InnoDB,\n PARTITION p201908SUB05 VALUES LESS THAN (737648) ENGINE = InnoDB,\n PARTITION p201908SUB06 VALUES LESS THAN (737650) ENGINE = InnoDB,\n PARTITION p201908SUB07 VALUES LESS THAN (737652) ENGINE = InnoDB,\n PARTITION p201908SUB08 VALUES LESS THAN (737654) ENGINE = InnoDB,\n PARTITION p201908SUB09 VALUES LESS THAN (737656) ENGINE = InnoDB,\n PARTITION p201908SUB10 VALUES LESS THAN (737658) ENGINE = InnoDB,\n PARTITION p201908SUB11 VALUES LESS THAN (737660) ENGINE = InnoDB,\n PARTITION p201908SUB12 VALUES LESS THAN (737662) ENGINE = InnoDB,\n PARTITION p201908SUB13 VALUES LESS THAN (737664) ENGINE = InnoDB,\n PARTITION p201908SUB14 VALUES LESS THAN (737666) ENGINE = InnoDB,\n PARTITION p201909SUB00 VALUES LESS THAN (737669) ENGINE = InnoDB,\n PARTITION p201909SUB01 VALUES LESS THAN (737671) ENGINE = InnoDB,\n PARTITION p201909SUB02 VALUES LESS THAN (737673) ENGINE = InnoDB,\n PARTITION p201909SUB03 VALUES LESS THAN (737675) ENGINE = InnoDB,\n PARTITION p201909SUB04 VALUES LESS THAN (737677) ENGINE = InnoDB,\n PARTITION p201909SUB05 VALUES LESS THAN (737679) ENGINE = InnoDB,\n PARTITION p201909SUB06 VALUES LESS THAN (737681) ENGINE = InnoDB,\n PARTITION p201909SUB07 VALUES LESS THAN (737683) ENGINE = InnoDB,\n PARTITION p201909SUB08 VALUES LESS THAN (737685) ENGINE = InnoDB,\n PARTITION p201909SUB09 VALUES LESS THAN (737687) ENGINE = InnoDB,\n PARTITION p201909SUB10 VALUES LESS THAN (737689) ENGINE = InnoDB,\n PARTITION p201909SUB11 VALUES LESS THAN (737691) ENGINE = InnoDB,\n PARTITION p201909SUB12 VALUES LESS THAN (737693) ENGINE = InnoDB,\n PARTITION p201909SUB13 VALUES LESS THAN (737695) ENGINE = InnoDB,\n PARTITION p201909SUB14 VALUES LESS THAN (737697) ENGINE = InnoDB,\n PARTITION p201910SUB00 VALUES LESS THAN (737699) ENGINE = InnoDB,\n PARTITION p201910SUB01 VALUES LESS THAN (737701) ENGINE = InnoDB,\n PARTITION p201910SUB02 VALUES LESS THAN (737703) ENGINE = InnoDB,\n PARTITION p201910SUB03 VALUES LESS THAN (737705) ENGINE = InnoDB,\n PARTITION p201910SUB04 VALUES LESS THAN (737707) ENGINE = InnoDB,\n PARTITION p201910SUB05 VALUES LESS THAN (737709) ENGINE = InnoDB,\n PARTITION p201910SUB06 VALUES LESS THAN (737711) ENGINE = InnoDB,\n PARTITION p201910SUB07 VALUES LESS THAN (737713) ENGINE = InnoDB,\n PARTITION p201910SUB08 VALUES LESS THAN (737715) ENGINE = InnoDB,\n PARTITION p201910SUB09 VALUES LESS THAN (737717) ENGINE = InnoDB,\n PARTITION p201910SUB10 VALUES LESS THAN (737719) ENGINE = InnoDB,\n PARTITION p201910SUB11 VALUES LESS THAN (737721) ENGINE = InnoDB,\n PARTITION p201910SUB12 VALUES LESS THAN (737723) ENGINE = InnoDB,\n PARTITION p201910SUB13 VALUES LESS THAN (737725) ENGINE = InnoDB,\n PARTITION p201910SUB14 VALUES LESS THAN (737727) ENGINE = InnoDB,\n PARTITION p201911SUB00 VALUES LESS THAN (737730) ENGINE = InnoDB,\n PARTITION p201911SUB01 VALUES LESS THAN (737732) ENGINE = InnoDB,\n PARTITION p201911SUB02 VALUES LESS THAN (737734) ENGINE = InnoDB,\n PARTITION p201911SUB03 VALUES LESS THAN (737736) ENGINE = InnoDB,\n PARTITION p201911SUB04 VALUES LESS THAN (737738) ENGINE = InnoDB,\n PARTITION p201911SUB05 VALUES LESS THAN (737740) ENGINE = InnoDB,\n PARTITION p201911SUB06 VALUES LESS THAN (737742) ENGINE = InnoDB,\n PARTITION p201911SUB07 VALUES LESS THAN (737744) ENGINE = InnoDB,\n PARTITION p201911SUB08 VALUES LESS THAN (737746) ENGINE = InnoDB,\n PARTITION p201911SUB09 VALUES LESS THAN (737748) ENGINE = InnoDB,\n PARTITION p201911SUB10 VALUES LESS THAN (737750) ENGINE = InnoDB,\n PARTITION p201911SUB11 VALUES LESS THAN (737752) ENGINE = InnoDB,\n PARTITION p201911SUB12 VALUES LESS THAN (737754) ENGINE = InnoDB,\n PARTITION p201911SUB13 VALUES LESS THAN (737756) ENGINE = InnoDB,\n PARTITION p201911SUB14 VALUES LESS THAN (737758) ENGINE = InnoDB,\n PARTITION p201912SUB00 VALUES LESS THAN (737760) ENGINE = InnoDB,\n PARTITION p201912SUB01 VALUES LESS THAN (737762) ENGINE = InnoDB,\n PARTITION p201912SUB02 VALUES LESS THAN (737764) ENGINE = InnoDB,\n PARTITION p201912SUB03 VALUES LESS THAN (737766) ENGINE = InnoDB,\n PARTITION p201912SUB04 VALUES LESS THAN (737768) ENGINE = InnoDB,\n PARTITION p201912SUB05 VALUES LESS THAN (737770) ENGINE = InnoDB,\n PARTITION p201912SUB06 VALUES LESS THAN (737772) ENGINE = InnoDB,\n PARTITION p201912SUB07 VALUES LESS THAN (737774) ENGINE = InnoDB,\n PARTITION p201912SUB08 VALUES LESS THAN (737776) ENGINE = InnoDB,\n PARTITION p201912SUB09 VALUES LESS THAN (737778) ENGINE = InnoDB,\n PARTITION p201912SUB10 VALUES LESS THAN (737780) ENGINE = InnoDB,\n PARTITION p201912SUB11 VALUES LESS THAN (737782) ENGINE = InnoDB,\n PARTITION p201912SUB12 VALUES LESS THAN (737784) ENGINE = InnoDB,\n PARTITION p201912SUB13 VALUES LESS THAN (737786) ENGINE = InnoDB,\n PARTITION p201912SUB14 VALUES LESS THAN (737788) ENGINE = InnoDB,\n PARTITION p202001SUB00 VALUES LESS THAN (737791) ENGINE = InnoDB,\n PARTITION p202001SUB01 VALUES LESS THAN (737793) ENGINE = InnoDB,\n PARTITION p202001SUB02 VALUES LESS THAN (737795) ENGINE = InnoDB,\n PARTITION p202001SUB03 VALUES LESS THAN (737797) ENGINE = InnoDB,\n PARTITION p202001SUB04 VALUES LESS THAN (737799) ENGINE = InnoDB,\n PARTITION p202001SUB05 VALUES LESS THAN (737801) ENGINE = InnoDB,\n PARTITION p202001SUB06 VALUES LESS THAN (737803) ENGINE = InnoDB,\n PARTITION p202001SUB07 VALUES LESS THAN (737805) ENGINE = InnoDB,\n PARTITION p202001SUB08 VALUES LESS THAN (737807) ENGINE = InnoDB,\n PARTITION p202001SUB09 VALUES LESS THAN (737809) ENGINE = InnoDB,\n PARTITION p202001SUB10 VALUES LESS THAN (737811) ENGINE = InnoDB,\n PARTITION p202001SUB11 VALUES LESS THAN (737813) ENGINE = InnoDB,\n PARTITION p202001SUB12 VALUES LESS THAN (737815) ENGINE = InnoDB,\n PARTITION p202001SUB13 VALUES LESS THAN (737817) ENGINE = InnoDB,\n PARTITION p202001SUB14 VALUES LESS THAN (737819) ENGINE = InnoDB,\n PARTITION p202002SUB00 VALUES LESS THAN (737822) ENGINE = InnoDB,\n PARTITION p202002SUB01 VALUES LESS THAN (737824) ENGINE = InnoDB,\n PARTITION p202002SUB02 VALUES LESS THAN (737826) ENGINE = InnoDB,\n PARTITION p202002SUB03 VALUES LESS THAN (737828) ENGINE = InnoDB,\n PARTITION p202002SUB04 VALUES LESS THAN (737830) ENGINE = InnoDB,\n PARTITION p202002SUB05 VALUES LESS THAN (737832) ENGINE = InnoDB,\n PARTITION p202002SUB06 VALUES LESS THAN (737834) ENGINE = InnoDB,\n PARTITION p202002SUB07 VALUES LESS THAN (737836) ENGINE = InnoDB,\n PARTITION p202002SUB08 VALUES LESS THAN (737838) ENGINE = InnoDB,\n PARTITION p202002SUB09 VALUES LESS THAN (737840) ENGINE = InnoDB,\n PARTITION p202002SUB10 VALUES LESS THAN (737842) ENGINE = InnoDB,\n PARTITION p202002SUB11 VALUES LESS THAN (737844) ENGINE = InnoDB,\n PARTITION p202002SUB12 VALUES LESS THAN (737846) ENGINE = InnoDB,\n PARTITION p202002SUB13 VALUES LESS THAN (737848) ENGINE = InnoDB,\n PARTITION p202003SUB00 VALUES LESS THAN (737851) ENGINE = InnoDB,\n PARTITION p202003SUB01 VALUES LESS THAN (737853) ENGINE = InnoDB,\n PARTITION p202003SUB02 VALUES LESS THAN (737855) ENGINE = InnoDB,\n PARTITION p202003SUB03 VALUES LESS THAN (737857) ENGINE = InnoDB,\n PARTITION p202003SUB04 VALUES LESS THAN (737859) ENGINE = InnoDB,\n PARTITION p202003SUB05 VALUES LESS THAN (737861) ENGINE = InnoDB,\n PARTITION p202003SUB06 VALUES LESS THAN (737863) ENGINE = InnoDB,\n PARTITION p202003SUB07 VALUES LESS THAN (737865) ENGINE = InnoDB,\n PARTITION p202003SUB08 VALUES LESS THAN (737867) ENGINE = InnoDB,\n PARTITION p202003SUB09 VALUES LESS THAN (737869) ENGINE = InnoDB,\n PARTITION p202003SUB10 VALUES LESS THAN (737871) ENGINE = InnoDB,\n PARTITION p202003SUB11 VALUES LESS THAN (737873) ENGINE = InnoDB,\n PARTITION p202003SUB12 VALUES LESS THAN (737875) ENGINE = InnoDB,\n PARTITION p202003SUB13 VALUES LESS THAN (737877) ENGINE = InnoDB,\n PARTITION p202003SUB14 VALUES LESS THAN (737879) ENGINE = InnoDB,\n PARTITION p202004SUB00 VALUES LESS THAN (737882) ENGINE = InnoDB,\n PARTITION p202004SUB01 VALUES LESS THAN (737884) ENGINE = InnoDB,\n PARTITION p202004SUB02 VALUES LESS THAN (737886) ENGINE = InnoDB,\n PARTITION p202004SUB03 VALUES LESS THAN (737888) ENGINE = InnoDB,\n PARTITION p202004SUB04 VALUES LESS THAN (737890) ENGINE = InnoDB,\n PARTITION p202004SUB05 VALUES LESS THAN (737892) ENGINE = InnoDB,\n PARTITION p202004SUB06 VALUES LESS THAN (737894) ENGINE = InnoDB,\n PARTITION p202004SUB07 VALUES LESS THAN (737896) ENGINE = InnoDB,\n PARTITION p202004SUB08 VALUES LESS THAN (737898) ENGINE = InnoDB,\n PARTITION p202004SUB09 VALUES LESS THAN (737900) ENGINE = InnoDB,\n PARTITION p202004SUB10 VALUES LESS THAN (737902) ENGINE = InnoDB,\n PARTITION p202004SUB11 VALUES LESS THAN (737904) ENGINE = InnoDB,\n PARTITION p202004SUB12 VALUES LESS THAN (737906) ENGINE = InnoDB,\n PARTITION p202004SUB13 VALUES LESS THAN (737908) ENGINE = InnoDB,\n PARTITION p202004SUB14 VALUES LESS THAN (737910) ENGINE = InnoDB,\n PARTITION p202005SUB00 VALUES LESS THAN (737912) ENGINE = InnoDB,\n PARTITION p202005SUB01 VALUES LESS THAN (737914) ENGINE = InnoDB,\n PARTITION p202005SUB02 VALUES LESS THAN (737916) ENGINE = InnoDB,\n PARTITION p202005SUB03 VALUES LESS THAN (737918) ENGINE = InnoDB,\n PARTITION p202005SUB04 VALUES LESS THAN (737920) ENGINE = InnoDB,\n PARTITION p202005SUB05 VALUES LESS THAN (737922) ENGINE = InnoDB,\n PARTITION p202005SUB06 VALUES LESS THAN (737924) ENGINE = InnoDB,\n PARTITION p202005SUB07 VALUES LESS THAN (737926) ENGINE = InnoDB,\n PARTITION p202005SUB08 VALUES LESS THAN (737928) ENGINE = InnoDB,\n PARTITION p202005SUB09 VALUES LESS THAN (737930) ENGINE = InnoDB,\n PARTITION p202005SUB10 VALUES LESS THAN (737932) ENGINE = InnoDB,\n PARTITION p202005SUB11 VALUES LESS THAN (737934) ENGINE = InnoDB,\n PARTITION p202005SUB12 VALUES LESS THAN (737936) ENGINE = InnoDB,\n PARTITION p202005SUB13 VALUES LESS THAN (737938) ENGINE = InnoDB,\n PARTITION p202005SUB14 VALUES LESS THAN (737940) ENGINE = InnoDB,\n PARTITION p202006SUB00 VALUES LESS THAN (737943) ENGINE = InnoDB,\n PARTITION p202006SUB01 VALUES LESS THAN (737945) ENGINE = InnoDB,\n PARTITION p202006SUB02 VALUES LESS THAN (737947) ENGINE = InnoDB,\n PARTITION p202006SUB03 VALUES LESS THAN (737949) ENGINE = InnoDB,\n PARTITION p202006SUB04 VALUES LESS THAN (737951) ENGINE = InnoDB,\n PARTITION p202006SUB05 VALUES LESS THAN (737953) ENGINE = InnoDB,\n PARTITION p202006SUB06 VALUES LESS THAN (737955) ENGINE = InnoDB,\n PARTITION p202006SUB07 VALUES LESS THAN (737957) ENGINE = InnoDB,\n PARTITION p202006SUB08 VALUES LESS THAN (737959) ENGINE = InnoDB,\n PARTITION p202006SUB09 VALUES LESS THAN (737961) ENGINE = InnoDB,\n PARTITION p202006SUB10 VALUES LESS THAN (737963) ENGINE = InnoDB,\n PARTITION p202006SUB11 VALUES LESS THAN (737965) ENGINE = InnoDB,\n PARTITION p202006SUB12 VALUES LESS THAN (737967) ENGINE = InnoDB,\n PARTITION p202006SUB13 VALUES LESS THAN (737969) ENGINE = InnoDB,\n PARTITION p202006SUB14 VALUES LESS THAN (737971) ENGINE = InnoDB,\n PARTITION p202007SUB00 VALUES LESS THAN (737973) ENGINE = InnoDB,\n PARTITION p202007SUB01 VALUES LESS THAN (737975) ENGINE = InnoDB,\n PARTITION p202007SUB02 VALUES LESS THAN (737977) ENGINE = InnoDB,\n PARTITION p202007SUB03 VALUES LESS THAN (737979) ENGINE = InnoDB,\n PARTITION p202007SUB04 VALUES LESS THAN (737981) ENGINE = InnoDB,\n PARTITION p202007SUB05 VALUES LESS THAN (737983) ENGINE = InnoDB,\n PARTITION p202007SUB06 VALUES LESS THAN (737985) ENGINE = InnoDB,\n PARTITION p202007SUB07 VALUES LESS THAN (737987) ENGINE = InnoDB,\n PARTITION p202007SUB08 VALUES LESS THAN (737989) ENGINE = InnoDB,\n PARTITION p202007SUB09 VALUES LESS THAN (737991) ENGINE = InnoDB,\n PARTITION p202007SUB10 VALUES LESS THAN (737993) ENGINE = InnoDB,\n PARTITION p202007SUB11 VALUES LESS THAN (737995) ENGINE = InnoDB,\n PARTITION p202007SUB12 VALUES LESS THAN (737997) ENGINE = InnoDB,\n PARTITION p202007SUB13 VALUES LESS THAN (737999) ENGINE = InnoDB,\n PARTITION p202007SUB14 VALUES LESS THAN (738001) ENGINE = InnoDB,\n PARTITION p202008SUB00 VALUES LESS THAN (738004) ENGINE = InnoDB,\n PARTITION p202008SUB01 VALUES LESS THAN (738006) ENGINE = InnoDB,\n PARTITION p202008SUB02 VALUES LESS THAN (738008) ENGINE = InnoDB,\n PARTITION p202008SUB03 VALUES LESS THAN (738010) ENGINE = InnoDB,\n PARTITION p202008SUB04 VALUES LESS THAN (738012) ENGINE = InnoDB,\n PARTITION p202008SUB05 VALUES LESS THAN (738014) ENGINE = InnoDB,\n PARTITION p202008SUB06 VALUES LESS THAN (738016) ENGINE = InnoDB,\n PARTITION p202008SUB07 VALUES LESS THAN (738018) ENGINE = InnoDB,\n PARTITION p202008SUB08 VALUES LESS THAN (738020) ENGINE = InnoDB,\n PARTITION p202008SUB09 VALUES LESS THAN (738022) ENGINE = InnoDB,\n PARTITION p202008SUB10 VALUES LESS THAN (738024) ENGINE = InnoDB,\n PARTITION p202008SUB11 VALUES LESS THAN (738026) ENGINE = InnoDB,\n PARTITION p202008SUB12 VALUES LESS THAN (738028) ENGINE = InnoDB,\n PARTITION p202008SUB13 VALUES LESS THAN (738030) ENGINE = InnoDB,\n PARTITION p202008SUB14 VALUES LESS THAN (738032) ENGINE = InnoDB,\n PARTITION p202009SUB00 VALUES LESS THAN (738035) ENGINE = InnoDB,\n PARTITION p202009SUB01 VALUES LESS THAN (738037) ENGINE = InnoDB,\n PARTITION p202009SUB02 VALUES LESS THAN (738039) ENGINE = InnoDB,\n PARTITION p202009SUB03 VALUES LESS THAN (738041) ENGINE = InnoDB,\n PARTITION p202009SUB04 VALUES LESS THAN (738043) ENGINE = InnoDB,\n PARTITION p202009SUB05 VALUES LESS THAN (738045) ENGINE = InnoDB,\n PARTITION p202009SUB06 VALUES LESS THAN (738047) ENGINE = InnoDB,\n PARTITION p202009SUB07 VALUES LESS THAN (738049) ENGINE = InnoDB,\n PARTITION p202009SUB08 VALUES LESS THAN (738051) ENGINE = InnoDB,\n PARTITION p202009SUB09 VALUES LESS THAN (738053) ENGINE = InnoDB,\n PARTITION p202009SUB10 VALUES LESS THAN (738055) ENGINE = InnoDB,\n PARTITION p202009SUB11 VALUES LESS THAN (738057) ENGINE = InnoDB,\n PARTITION p202009SUB12 VALUES LESS THAN (738059) ENGINE = InnoDB,\n PARTITION p202009SUB13 VALUES LESS THAN (738061) ENGINE = InnoDB,\n PARTITION p202009SUB14 VALUES LESS THAN (738063) ENGINE = InnoDB,\n PARTITION p202010SUB00 VALUES LESS THAN (738065) ENGINE = InnoDB,\n PARTITION p202010SUB01 VALUES LESS THAN (738067) ENGINE = InnoDB,\n PARTITION p202010SUB02 VALUES LESS THAN (738069) ENGINE = InnoDB,\n PARTITION p202010SUB03 VALUES LESS THAN (738071) ENGINE = InnoDB,\n PARTITION p202010SUB04 VALUES LESS THAN (738073) ENGINE = InnoDB,\n PARTITION p202010SUB05 VALUES LESS THAN (738075) ENGINE = InnoDB,\n PARTITION p202010SUB06 VALUES LESS THAN (738077) ENGINE = InnoDB,\n PARTITION p202010SUB07 VALUES LESS THAN (738079) ENGINE = InnoDB,\n PARTITION p202010SUB08 VALUES LESS THAN (738081) ENGINE = InnoDB,\n PARTITION p202010SUB09 VALUES LESS THAN (738083) ENGINE = InnoDB,\n PARTITION p202010SUB10 VALUES LESS THAN (738085) ENGINE = InnoDB,\n PARTITION p202010SUB11 VALUES LESS THAN (738087) ENGINE = InnoDB,\n PARTITION p202010SUB12 VALUES LESS THAN (738089) ENGINE = InnoDB,\n PARTITION p202010SUB13 VALUES LESS THAN (738091) ENGINE = InnoDB,\n PARTITION p202010SUB14 VALUES LESS THAN (738093) ENGINE = InnoDB,\n PARTITION p202011SUB00 VALUES LESS THAN (738096) ENGINE = InnoDB,\n PARTITION p202011SUB01 VALUES LESS THAN (738098) ENGINE = InnoDB,\n PARTITION p202011SUB02 VALUES LESS THAN (738100) ENGINE = InnoDB,\n PARTITION p202011SUB03 VALUES LESS THAN (738102) ENGINE = InnoDB,\n PARTITION p202011SUB04 VALUES LESS THAN (738104) ENGINE = InnoDB,\n PARTITION p202011SUB05 VALUES LESS THAN (738106) ENGINE = InnoDB,\n PARTITION p202011SUB06 VALUES LESS THAN (738108) ENGINE = InnoDB,\n PARTITION p202011SUB07 VALUES LESS THAN (738110) ENGINE = InnoDB,\n PARTITION p202011SUB08 VALUES LESS THAN (738112) ENGINE = InnoDB,\n PARTITION p202011SUB09 VALUES LESS THAN (738114) ENGINE = InnoDB,\n PARTITION p202011SUB10 VALUES LESS THAN (738116) ENGINE = InnoDB,\n PARTITION p202011SUB11 VALUES LESS THAN (738118) ENGINE = InnoDB,\n PARTITION p202011SUB12 VALUES LESS THAN (738120) ENGINE = InnoDB,\n PARTITION p202011SUB13 VALUES LESS THAN (738122) ENGINE = InnoDB,\n PARTITION p202011SUB14 VALUES LESS THAN (738124) ENGINE = InnoDB,\n PARTITION p202012SUB00 VALUES LESS THAN (738126) ENGINE = InnoDB,\n PARTITION p202012SUB01 VALUES LESS THAN (738128) ENGINE = InnoDB,\n PARTITION p202012SUB02 VALUES LESS THAN (738130) ENGINE = InnoDB,\n PARTITION p202012SUB03 VALUES LESS THAN (738132) ENGINE = InnoDB,\n PARTITION p202012SUB04 VALUES LESS THAN (738134) ENGINE = InnoDB,\n PARTITION p202012SUB05 VALUES LESS THAN (738136) ENGINE = InnoDB,\n PARTITION p202012SUB06 VALUES LESS THAN (738138) ENGINE = InnoDB,\n PARTITION p202012SUB07 VALUES LESS THAN (738140) ENGINE = InnoDB,\n PARTITION p202012SUB08 VALUES LESS THAN (738142) ENGINE = InnoDB,\n PARTITION p202012SUB09 VALUES LESS THAN (738144) ENGINE = InnoDB,\n PARTITION p202012SUB10 VALUES LESS THAN (738146) ENGINE = InnoDB,\n PARTITION p202012SUB11 VALUES LESS THAN (738148) ENGINE = InnoDB,\n PARTITION p202012SUB12 VALUES LESS THAN (738150) ENGINE = InnoDB,\n PARTITION p202012SUB13 VALUES LESS THAN (738152) ENGINE = InnoDB,\n PARTITION p202012SUB14 VALUES LESS THAN (738154) ENGINE = InnoDB,\n PARTITION p202101SUB00 VALUES LESS THAN (738157) ENGINE = InnoDB,\n PARTITION p202101SUB01 VALUES LESS THAN (738159) ENGINE = InnoDB,\n PARTITION p202101SUB02 VALUES LESS THAN (738161) ENGINE = InnoDB,\n PARTITION p202101SUB03 VALUES LESS THAN (738163) ENGINE = InnoDB,\n PARTITION p202101SUB04 VALUES LESS THAN (738165) ENGINE = InnoDB,\n PARTITION p202101SUB05 VALUES LESS THAN (738167) ENGINE = InnoDB,\n PARTITION p202101SUB06 VALUES LESS THAN (738169) ENGINE = InnoDB,\n PARTITION p202101SUB07 VALUES LESS THAN (738171) ENGINE = InnoDB,\n PARTITION p202101SUB08 VALUES LESS THAN (738173) ENGINE = InnoDB,\n PARTITION p202101SUB09 VALUES LESS THAN (738175) ENGINE = InnoDB,\n PARTITION p202101SUB10 VALUES LESS THAN (738177) ENGINE = InnoDB,\n PARTITION p202101SUB11 VALUES LESS THAN (738179) ENGINE = InnoDB,\n PARTITION p202101SUB12 VALUES LESS THAN (738181) ENGINE = InnoDB,\n PARTITION p202101SUB13 VALUES LESS THAN (738183) ENGINE = InnoDB,\n PARTITION p202101SUB14 VALUES LESS THAN (738185) ENGINE = InnoDB,\n PARTITION p202102SUB00 VALUES LESS THAN (738188) ENGINE = InnoDB,\n PARTITION p202102SUB01 VALUES LESS THAN (738190) ENGINE = InnoDB,\n PARTITION p202102SUB02 VALUES LESS THAN (738192) ENGINE = InnoDB,\n PARTITION p202102SUB03 VALUES LESS THAN (738194) ENGINE = InnoDB,\n PARTITION p202102SUB04 VALUES LESS THAN (738196) ENGINE = InnoDB,\n PARTITION p202102SUB05 VALUES LESS THAN (738198) ENGINE = InnoDB,\n PARTITION p202102SUB06 VALUES LESS THAN (738200) ENGINE = InnoDB,\n PARTITION p202102SUB07 VALUES LESS THAN (738202) ENGINE = InnoDB,\n PARTITION p202102SUB08 VALUES LESS THAN (738204) ENGINE = InnoDB,\n PARTITION p202102SUB09 VALUES LESS THAN (738206) ENGINE = InnoDB,\n PARTITION p202102SUB10 VALUES LESS THAN (738208) ENGINE = InnoDB,\n PARTITION p202102SUB11 VALUES LESS THAN (738210) ENGINE = InnoDB,\n PARTITION p202102SUB12 VALUES LESS THAN (738212) ENGINE = InnoDB,\n PARTITION p202102SUB13 VALUES LESS THAN (738214) ENGINE = InnoDB,\n PARTITION p202103SUB00 VALUES LESS THAN (738216) ENGINE = InnoDB,\n PARTITION p202103SUB01 VALUES LESS THAN (738218) ENGINE = InnoDB,\n PARTITION p202103SUB02 VALUES LESS THAN (738220) ENGINE = InnoDB,\n PARTITION p202103SUB03 VALUES LESS THAN (738222) ENGINE = InnoDB,\n PARTITION p202103SUB04 VALUES LESS THAN (738224) ENGINE = InnoDB,\n PARTITION p202103SUB05 VALUES LESS THAN (738226) ENGINE = InnoDB,\n PARTITION p202103SUB06 VALUES LESS THAN (738228) ENGINE = InnoDB,\n PARTITION p202103SUB07 VALUES LESS THAN (738230) ENGINE = InnoDB,\n PARTITION p202103SUB08 VALUES LESS THAN (738232) ENGINE = InnoDB,\n PARTITION p202103SUB09 VALUES LESS THAN (738234) ENGINE = InnoDB,\n PARTITION p202103SUB10 VALUES LESS THAN (738236) ENGINE = InnoDB,\n PARTITION p202103SUB11 VALUES LESS THAN (738238) ENGINE = InnoDB,\n PARTITION p202103SUB12 VALUES LESS THAN (738240) ENGINE = InnoDB,\n PARTITION p202103SUB13 VALUES LESS THAN (738242) ENGINE = InnoDB,\n PARTITION p202103SUB14 VALUES LESS THAN (738244) ENGINE = InnoDB,\n PARTITION p202104SUB00 VALUES LESS THAN (738247) ENGINE = InnoDB,\n PARTITION p202104SUB01 VALUES LESS THAN (738249) ENGINE = InnoDB,\n PARTITION p202104SUB02 VALUES LESS THAN (738251) ENGINE = InnoDB,\n PARTITION p202104SUB03 VALUES LESS THAN (738253) ENGINE = InnoDB,\n PARTITION p202104SUB04 VALUES LESS THAN (738255) ENGINE = InnoDB,\n PARTITION p202104SUB05 VALUES LESS THAN (738257) ENGINE = InnoDB,\n PARTITION p202104SUB06 VALUES LESS THAN (738259) ENGINE = InnoDB,\n PARTITION p202104SUB07 VALUES LESS THAN (738261) ENGINE = InnoDB,\n PARTITION p202104SUB08 VALUES LESS THAN (738263) ENGINE = InnoDB,\n PARTITION p202104SUB09 VALUES LESS THAN (738265) ENGINE = InnoDB,\n PARTITION p202104SUB10 VALUES LESS THAN (738267) ENGINE = InnoDB,\n PARTITION p202104SUB11 VALUES LESS THAN (738269) ENGINE = InnoDB,\n PARTITION p202104SUB12 VALUES LESS THAN (738271) ENGINE = InnoDB,\n PARTITION p202104SUB13 VALUES LESS THAN (738273) ENGINE = InnoDB,\n PARTITION p202104SUB14 VALUES LESS THAN (738275) ENGINE = InnoDB,\n PARTITION p202105SUB00 VALUES LESS THAN (738277) ENGINE = InnoDB,\n PARTITION p202105SUB01 VALUES LESS THAN (738279) ENGINE = InnoDB,\n PARTITION p202105SUB02 VALUES LESS THAN (738281) ENGINE = InnoDB,\n PARTITION p202105SUB03 VALUES LESS THAN (738283) ENGINE = InnoDB,\n PARTITION p202105SUB04 VALUES LESS THAN (738285) ENGINE = InnoDB,\n PARTITION p202105SUB05 VALUES LESS THAN (738287) ENGINE = InnoDB,\n PARTITION p202105SUB06 VALUES LESS THAN (738289) ENGINE = InnoDB,\n PARTITION p202105SUB07 VALUES LESS THAN (738291) ENGINE = InnoDB,\n PARTITION p202105SUB08 VALUES LESS THAN (738293) ENGINE = InnoDB,\n PARTITION p202105SUB09 VALUES LESS THAN (738295) ENGINE = InnoDB,\n PARTITION p202105SUB10 VALUES LESS THAN (738297) ENGINE = InnoDB,\n PARTITION p202105SUB11 VALUES LESS THAN (738299) ENGINE = InnoDB,\n PARTITION p202105SUB12 VALUES LESS THAN (738301) ENGINE = InnoDB,\n PARTITION p202105SUB13 VALUES LESS THAN (738303) ENGINE = InnoDB,\n PARTITION p202105SUB14 VALUES LESS THAN (738305) ENGINE = InnoDB,\n PARTITION p202106SUB00 VALUES LESS THAN (738308) ENGINE = InnoDB,\n PARTITION p202106SUB01 VALUES LESS THAN (738310) ENGINE = InnoDB,\n PARTITION p202106SUB02 VALUES LESS THAN (738312) ENGINE = InnoDB,\n PARTITION p202106SUB03 VALUES LESS THAN (738314) ENGINE = InnoDB,\n PARTITION p202106SUB04 VALUES LESS THAN (738316) ENGINE = InnoDB,\n PARTITION p202106SUB05 VALUES LESS THAN (738318) ENGINE = InnoDB,\n PARTITION p202106SUB06 VALUES LESS THAN (738320) ENGINE = InnoDB,\n PARTITION p202106SUB07 VALUES LESS THAN (738322) ENGINE = InnoDB,\n PARTITION p202106SUB08 VALUES LESS THAN (738324) ENGINE = InnoDB,\n PARTITION p202106SUB09 VALUES LESS THAN (738326) ENGINE = InnoDB,\n PARTITION p202106SUB10 VALUES LESS THAN (738328) ENGINE = InnoDB,\n PARTITION p202106SUB11 VALUES LESS THAN (738330) ENGINE = InnoDB,\n PARTITION p202106SUB12 VALUES LESS THAN (738332) ENGINE = InnoDB,\n PARTITION p202106SUB13 VALUES LESS THAN (738334) ENGINE = InnoDB,\n PARTITION p202106SUB14 VALUES LESS THAN (738336) ENGINE = InnoDB,\n PARTITION p202107SUB00 VALUES LESS THAN (738338) ENGINE = InnoDB,\n PARTITION p202107SUB01 VALUES LESS THAN (738340) ENGINE = InnoDB,\n PARTITION p202107SUB02 VALUES LESS THAN (738342) ENGINE = InnoDB,\n PARTITION p202107SUB03 VALUES LESS THAN (738344) ENGINE = InnoDB,\n PARTITION p202107SUB04 VALUES LESS THAN (738346) ENGINE = InnoDB,\n PARTITION p202107SUB05 VALUES LESS THAN (738348) ENGINE = InnoDB,\n PARTITION p202107SUB06 VALUES LESS THAN (738350) ENGINE = InnoDB,\n PARTITION p202107SUB07 VALUES LESS THAN (738352) ENGINE = InnoDB,\n PARTITION p202107SUB08 VALUES LESS THAN (738354) ENGINE = InnoDB,\n PARTITION p202107SUB09 VALUES LESS THAN (738356) ENGINE = InnoDB,\n PARTITION p202107SUB10 VALUES LESS THAN (738358) ENGINE = InnoDB,\n PARTITION p202107SUB11 VALUES LESS THAN (738360) ENGINE = InnoDB,\n PARTITION p202107SUB12 VALUES LESS THAN (738362) ENGINE = InnoDB,\n PARTITION p202107SUB13 VALUES LESS THAN (738364) ENGINE = InnoDB,\n PARTITION p202107SUB14 VALUES LESS THAN (738366) ENGINE = InnoDB,\n PARTITION p202108SUB00 VALUES LESS THAN (738369) ENGINE = InnoDB,\n PARTITION p202108SUB01 VALUES LESS THAN (738371) ENGINE = InnoDB,\n PARTITION p202108SUB02 VALUES LESS THAN (738373) ENGINE = InnoDB,\n PARTITION p202108SUB03 VALUES LESS THAN (738375) ENGINE = InnoDB,\n PARTITION p202108SUB04 VALUES LESS THAN (738377) ENGINE = InnoDB,\n PARTITION p202108SUB05 VALUES LESS THAN (738379) ENGINE = InnoDB,\n PARTITION p202108SUB06 VALUES LESS THAN (738381) ENGINE = InnoDB,\n PARTITION p202108SUB07 VALUES LESS THAN (738383) ENGINE = InnoDB,\n PARTITION p202108SUB08 VALUES LESS THAN (738385) ENGINE = InnoDB,\n PARTITION p202108SUB09 VALUES LESS THAN (738387) ENGINE = InnoDB,\n PARTITION p202108SUB10 VALUES LESS THAN (738389) ENGINE = InnoDB,\n PARTITION p202108SUB11 VALUES LESS THAN (738391) ENGINE = InnoDB,\n PARTITION p202108SUB12 VALUES LESS THAN (738393) ENGINE = InnoDB,\n PARTITION p202108SUB13 VALUES LESS THAN (738395) ENGINE = InnoDB,\n PARTITION p202108SUB14 VALUES LESS THAN (738397) ENGINE = InnoDB,\n PARTITION p202109SUB00 VALUES LESS THAN (738400) ENGINE = InnoDB,\n PARTITION p202109SUB01 VALUES LESS THAN (738402) ENGINE = InnoDB,\n PARTITION p202109SUB02 VALUES LESS THAN (738404) ENGINE = InnoDB,\n PARTITION p202109SUB03 VALUES LESS THAN (738406) ENGINE = InnoDB,\n PARTITION p202109SUB04 VALUES LESS THAN (738408) ENGINE = InnoDB,\n PARTITION p202109SUB05 VALUES LESS THAN (738410) ENGINE = InnoDB,\n PARTITION p202109SUB06 VALUES LESS THAN (738412) ENGINE = InnoDB,\n PARTITION p202109SUB07 VALUES LESS THAN (738414) ENGINE = InnoDB,\n PARTITION p202109SUB08 VALUES LESS THAN (738416) ENGINE = InnoDB,\n PARTITION p202109SUB09 VALUES LESS THAN (738418) ENGINE = InnoDB,\n PARTITION p202109SUB10 VALUES LESS THAN (738420) ENGINE = InnoDB,\n PARTITION p202109SUB11 VALUES LESS THAN (738422) ENGINE = InnoDB,\n PARTITION p202109SUB12 VALUES LESS THAN (738424) ENGINE = InnoDB,\n PARTITION p202109SUB13 VALUES LESS THAN (738426) ENGINE = InnoDB,\n PARTITION p202109SUB14 VALUES LESS THAN (738428) ENGINE = InnoDB,\n PARTITION p202110SUB00 VALUES LESS THAN (738430) ENGINE = InnoDB,\n PARTITION p202110SUB01 VALUES LESS THAN (738432) ENGINE = InnoDB,\n PARTITION p202110SUB02 VALUES LESS THAN (738434) ENGINE = InnoDB,\n PARTITION p202110SUB03 VALUES LESS THAN (738436) ENGINE = InnoDB,\n PARTITION p202110SUB04 VALUES LESS THAN (738438) ENGINE = InnoDB,\n PARTITION p202110SUB05 VALUES LESS THAN (738440) ENGINE = InnoDB,\n PARTITION p202110SUB06 VALUES LESS THAN (738442) ENGINE = InnoDB,\n PARTITION p202110SUB07 VALUES LESS THAN (738444) ENGINE = InnoDB,\n PARTITION p202110SUB08 VALUES LESS THAN (738446) ENGINE = InnoDB,\n PARTITION p202110SUB09 VALUES LESS THAN (738448) ENGINE = InnoDB,\n PARTITION p202110SUB10 VALUES LESS THAN (738450) ENGINE = InnoDB,\n PARTITION p202110SUB11 VALUES LESS THAN (738452) ENGINE = InnoDB,\n PARTITION p202110SUB12 VALUES LESS THAN (738454) ENGINE = InnoDB,\n PARTITION p202110SUB13 VALUES LESS THAN (738456) ENGINE = InnoDB,\n PARTITION p202110SUB14 VALUES LESS THAN (738458) ENGINE = InnoDB,\n PARTITION p202111SUB00 VALUES LESS THAN (738461) ENGINE = InnoDB,\n PARTITION p202111SUB01 VALUES LESS THAN (738463) ENGINE = InnoDB,\n PARTITION p202111SUB02 VALUES LESS THAN (738465) ENGINE = InnoDB,\n PARTITION p202111SUB03 VALUES LESS THAN (738467) ENGINE = InnoDB,\n PARTITION p202111SUB04 VALUES LESS THAN (738469) ENGINE = InnoDB,\n PARTITION p202111SUB05 VALUES LESS THAN (738471) ENGINE = InnoDB,\n PARTITION p202111SUB06 VALUES LESS THAN (738473) ENGINE = InnoDB,\n PARTITION p202111SUB07 VALUES LESS THAN (738475) ENGINE = InnoDB,\n PARTITION p202111SUB08 VALUES LESS THAN (738477) ENGINE = InnoDB,\n PARTITION p202111SUB09 VALUES LESS THAN (738479) ENGINE = InnoDB,\n PARTITION p202111SUB10 VALUES LESS THAN (738481) ENGINE = InnoDB,\n PARTITION p202111SUB11 VALUES LESS THAN (738483) ENGINE = InnoDB,\n PARTITION p202111SUB12 VALUES LESS THAN (738485) ENGINE = InnoDB,\n PARTITION p202111SUB13 VALUES LESS THAN (738487) ENGINE = InnoDB,\n PARTITION p202111SUB14 VALUES LESS THAN (738489) ENGINE = InnoDB,\n PARTITION p202112SUB00 VALUES LESS THAN (738491) ENGINE = InnoDB,\n PARTITION p202112SUB01 VALUES LESS THAN (738493) ENGINE = InnoDB,\n PARTITION p202112SUB02 VALUES LESS THAN (738495) ENGINE = InnoDB,\n PARTITION p202112SUB03 VALUES LESS THAN (738497) ENGINE = InnoDB,\n PARTITION p202112SUB04 VALUES LESS THAN (738499) ENGINE = InnoDB,\n PARTITION p202112SUB05 VALUES LESS THAN (738501) ENGINE = InnoDB,\n PARTITION p202112SUB06 VALUES LESS THAN (738503) ENGINE = InnoDB,\n PARTITION p202112SUB07 VALUES LESS THAN (738505) ENGINE = InnoDB,\n PARTITION p202112SUB08 VALUES LESS THAN (738507) ENGINE = InnoDB,\n PARTITION p202112SUB09 VALUES LESS THAN (738509) ENGINE = InnoDB,\n PARTITION p202112SUB10 VALUES LESS THAN (738511) ENGINE = InnoDB,\n PARTITION p202112SUB11 VALUES LESS THAN (738513) ENGINE = InnoDB,\n PARTITION p202112SUB12 VALUES LESS THAN (738515) ENGINE = InnoDB,\n PARTITION p202112SUB13 VALUES LESS THAN (738517) ENGINE = InnoDB,\n PARTITION p202112SUB14 VALUES LESS THAN (738519) ENGINE = InnoDB,\n PARTITION p202201SUB00 VALUES LESS THAN (738522) ENGINE = InnoDB,\n PARTITION p202201SUB01 VALUES LESS THAN (738524) ENGINE = InnoDB,\n PARTITION p202201SUB02 VALUES LESS THAN (738526) ENGINE = InnoDB,\n PARTITION p202201SUB03 VALUES LESS THAN (738528) ENGINE = InnoDB,\n PARTITION p202201SUB04 VALUES LESS THAN (738530) ENGINE = InnoDB,\n PARTITION p202201SUB05 VALUES LESS THAN (738532) ENGINE = InnoDB,\n PARTITION p202201SUB06 VALUES LESS THAN (738534) ENGINE = InnoDB,\n PARTITION p202201SUB07 VALUES LESS THAN (738536) ENGINE = InnoDB,\n PARTITION p202201SUB08 VALUES LESS THAN (738538) ENGINE = InnoDB,\n PARTITION p202201SUB09 VALUES LESS THAN (738540) ENGINE = InnoDB,\n PARTITION p202201SUB10 VALUES LESS THAN (738542) ENGINE = InnoDB,\n PARTITION p202201SUB11 VALUES LESS THAN (738544) ENGINE = InnoDB,\n PARTITION p202201SUB12 VALUES LESS THAN (738546) ENGINE = InnoDB,\n PARTITION p202201SUB13 VALUES LESS THAN (738548) ENGINE = InnoDB,\n PARTITION p202201SUB14 VALUES LESS THAN (738550) ENGINE = InnoDB,\n PARTITION p202202SUB00 VALUES LESS THAN (738553) ENGINE = InnoDB,\n PARTITION p202202SUB01 VALUES LESS THAN (738555) ENGINE = InnoDB,\n PARTITION p202202SUB02 VALUES LESS THAN (738557) ENGINE = InnoDB,\n PARTITION p202202SUB03 VALUES LESS THAN (738559) ENGINE = InnoDB,\n PARTITION p202202SUB04 VALUES LESS THAN (738561) ENGINE = InnoDB,\n PARTITION p202202SUB05 VALUES LESS THAN (738563) ENGINE = InnoDB,\n PARTITION p202202SUB06 VALUES LESS THAN (738565) ENGINE = InnoDB,\n PARTITION p202202SUB07 VALUES LESS THAN (738567) ENGINE = InnoDB,\n PARTITION p202202SUB08 VALUES LESS THAN (738569) ENGINE = InnoDB,\n PARTITION p202202SUB09 VALUES LESS THAN (738571) ENGINE = InnoDB,\n PARTITION p202202SUB10 VALUES LESS THAN (738573) ENGINE = InnoDB,\n PARTITION p202202SUB11 VALUES LESS THAN (738575) ENGINE = InnoDB,\n PARTITION p202202SUB12 VALUES LESS THAN (738577) ENGINE = InnoDB,\n PARTITION p202202SUB13 VALUES LESS THAN (738579) ENGINE = InnoDB,\n PARTITION p202203SUB00 VALUES LESS THAN (738581) ENGINE = InnoDB,\n PARTITION p202203SUB01 VALUES LESS THAN (738583) ENGINE = InnoDB,\n PARTITION p202203SUB02 VALUES LESS THAN (738585) ENGINE = InnoDB,\n PARTITION p202203SUB03 VALUES LESS THAN (738587) ENGINE = InnoDB,\n PARTITION p202203SUB04 VALUES LESS THAN (738589) ENGINE = InnoDB,\n PARTITION p202203SUB05 VALUES LESS THAN (738591) ENGINE = InnoDB,\n PARTITION p202203SUB06 VALUES LESS THAN (738593) ENGINE = InnoDB,\n PARTITION p202203SUB07 VALUES LESS THAN (738595) ENGINE = InnoDB,\n PARTITION p202203SUB08 VALUES LESS THAN (738597) ENGINE = InnoDB,\n PARTITION p202203SUB09 VALUES LESS THAN (738599) ENGINE = InnoDB,\n PARTITION p202203SUB10 VALUES LESS THAN (738601) ENGINE = InnoDB,\n PARTITION p202203SUB11 VALUES LESS THAN (738603) ENGINE = InnoDB,\n PARTITION p202203SUB12 VALUES LESS THAN (738605) ENGINE = InnoDB,\n PARTITION p202203SUB13 VALUES LESS THAN (738607) ENGINE = InnoDB,\n PARTITION p202203SUB14 VALUES LESS THAN (738609) ENGINE = InnoDB,\n PARTITION p202204SUB00 VALUES LESS THAN (738612) ENGINE = InnoDB,\n PARTITION p202204SUB01 VALUES LESS THAN (738614) ENGINE = InnoDB,\n PARTITION p202204SUB02 VALUES LESS THAN (738616) ENGINE = InnoDB,\n PARTITION p202204SUB03 VALUES LESS THAN (738618) ENGINE = InnoDB,\n PARTITION p202204SUB04 VALUES LESS THAN (738620) ENGINE = InnoDB,\n PARTITION p202204SUB05 VALUES LESS THAN (738622) ENGINE = InnoDB,\n PARTITION p202204SUB06 VALUES LESS THAN (738624) ENGINE = InnoDB,\n PARTITION p202204SUB07 VALUES LESS THAN (738626) ENGINE = InnoDB,\n PARTITION p202204SUB08 VALUES LESS THAN (738628) ENGINE = InnoDB,\n PARTITION p202204SUB09 VALUES LESS THAN (738630) ENGINE = InnoDB,\n PARTITION p202204SUB10 VALUES LESS THAN (738632) ENGINE = InnoDB,\n PARTITION p202204SUB11 VALUES LESS THAN (738634) ENGINE = InnoDB,\n PARTITION p202204SUB12 VALUES LESS THAN (738636) ENGINE = InnoDB,\n PARTITION p202204SUB13 VALUES LESS THAN (738638) ENGINE = InnoDB,\n PARTITION p202204SUB14 VALUES LESS THAN (738640) ENGINE = InnoDB,\n PARTITION p202205SUB00 VALUES LESS THAN (738642) ENGINE = InnoDB,\n PARTITION p202205SUB01 VALUES LESS THAN (738644) ENGINE = InnoDB,\n PARTITION p202205SUB02 VALUES LESS THAN (738646) ENGINE = InnoDB,\n PARTITION p202205SUB03 VALUES LESS THAN (738648) ENGINE = InnoDB,\n PARTITION p202205SUB04 VALUES LESS THAN (738650) ENGINE = InnoDB,\n PARTITION p202205SUB05 VALUES LESS THAN (738652) ENGINE = InnoDB,\n PARTITION p202205SUB06 VALUES LESS THAN (738654) ENGINE = InnoDB,\n PARTITION p202205SUB07 VALUES LESS THAN (738656) ENGINE = InnoDB,\n PARTITION p202205SUB08 VALUES LESS THAN (738658) ENGINE = InnoDB,\n PARTITION p202205SUB09 VALUES LESS THAN (738660) ENGINE = InnoDB,\n PARTITION p202205SUB10 VALUES LESS THAN (738662) ENGINE = InnoDB,\n PARTITION p202205SUB11 VALUES LESS THAN (738664) ENGINE = InnoDB,\n PARTITION p202205SUB12 VALUES LESS THAN (738666) ENGINE = InnoDB,\n PARTITION p202205SUB13 VALUES LESS THAN (738668) ENGINE = InnoDB,\n PARTITION p202205SUB14 VALUES LESS THAN (738670) ENGINE = InnoDB,\n PARTITION p202206SUB00 VALUES LESS THAN (738673) ENGINE = InnoDB,\n PARTITION p202206SUB01 VALUES LESS THAN (738675) ENGINE = InnoDB,\n PARTITION p202206SUB02 VALUES LESS THAN (738677) ENGINE = InnoDB,\n PARTITION p202206SUB03 VALUES LESS THAN (738679) ENGINE = InnoDB,\n PARTITION p202206SUB04 VALUES LESS THAN (738681) ENGINE = InnoDB,\n PARTITION p202206SUB05 VALUES LESS THAN (738683) ENGINE = InnoDB,\n PARTITION p202206SUB06 VALUES LESS THAN (738685) ENGINE = InnoDB,\n PARTITION p202206SUB07 VALUES LESS THAN (738687) ENGINE = InnoDB,\n PARTITION p202206SUB08 VALUES LESS THAN (738689) ENGINE = InnoDB,\n PARTITION p202206SUB09 VALUES LESS THAN (738691) ENGINE = InnoDB,\n PARTITION p202206SUB10 VALUES LESS THAN (738693) ENGINE = InnoDB,\n PARTITION p202206SUB11 VALUES LESS THAN (738695) ENGINE = InnoDB,\n PARTITION p202206SUB12 VALUES LESS THAN (738697) ENGINE = InnoDB,\n PARTITION p202206SUB13 VALUES LESS THAN (738699) ENGINE = InnoDB,\n PARTITION p202206SUB14 VALUES LESS THAN (738701) ENGINE = InnoDB,\n PARTITION p202207SUB00 VALUES LESS THAN (738703) ENGINE = InnoDB,\n PARTITION p202207SUB01 VALUES LESS THAN (738705) ENGINE = InnoDB,\n PARTITION p202207SUB02 VALUES LESS THAN (738707) ENGINE = InnoDB,\n PARTITION p202207SUB03 VALUES LESS THAN (738709) ENGINE = InnoDB,\n PARTITION p202207SUB04 VALUES LESS THAN (738711) ENGINE = InnoDB,\n PARTITION p202207SUB05 VALUES LESS THAN (738713) ENGINE = InnoDB,\n PARTITION p202207SUB06 VALUES LESS THAN (738715) ENGINE = InnoDB,\n PARTITION p202207SUB07 VALUES LESS THAN (738717) ENGINE = InnoDB,\n PARTITION p202207SUB08 VALUES LESS THAN (738719) ENGINE = InnoDB,\n PARTITION p202207SUB09 VALUES LESS THAN (738721) ENGINE = InnoDB,\n PARTITION p202207SUB10 VALUES LESS THAN (738723) ENGINE = InnoDB,\n PARTITION p202207SUB11 VALUES LESS THAN (738725) ENGINE = InnoDB,\n PARTITION p202207SUB12 VALUES LESS THAN (738727) ENGINE = InnoDB,\n PARTITION p202207SUB13 VALUES LESS THAN (738729) ENGINE = InnoDB,\n PARTITION p202207SUB14 VALUES LESS THAN (738731) ENGINE = InnoDB,\n PARTITION p202208SUB00 VALUES LESS THAN (738734) ENGINE = InnoDB,\n PARTITION p202208SUB01 VALUES LESS THAN (738736) ENGINE = InnoDB,\n PARTITION p202208SUB02 VALUES LESS THAN (738738) ENGINE = InnoDB,\n PARTITION p202208SUB03 VALUES LESS THAN (738740) ENGINE = InnoDB,\n PARTITION p202208SUB04 VALUES LESS THAN (738742) ENGINE = InnoDB,\n PARTITION p202208SUB05 VALUES LESS THAN (738744) ENGINE = InnoDB,\n PARTITION p202208SUB06 VALUES LESS THAN (738746) ENGINE = InnoDB,\n PARTITION p202208SUB07 VALUES LESS THAN (738748) ENGINE = InnoDB,\n PARTITION p202208SUB08 VALUES LESS THAN (738750) ENGINE = InnoDB,\n PARTITION p202208SUB09 VALUES LESS THAN (738752) ENGINE = InnoDB,\n PARTITION p202208SUB10 VALUES LESS THAN (738754) ENGINE = InnoDB,\n PARTITION p202208SUB11 VALUES LESS THAN (738756) ENGINE = InnoDB,\n PARTITION p202208SUB12 VALUES LESS THAN (738758) ENGINE = InnoDB,\n PARTITION p202208SUB13 VALUES LESS THAN (738760) ENGINE = InnoDB,\n PARTITION p202208SUB14 VALUES LESS THAN (738762) ENGINE = InnoDB,\n PARTITION p202209SUB00 VALUES LESS THAN (738765) ENGINE = InnoDB,\n PARTITION p202209SUB01 VALUES LESS THAN (738767) ENGINE = InnoDB,\n PARTITION p202209SUB02 VALUES LESS THAN (738769) ENGINE = InnoDB,\n PARTITION p202209SUB03 VALUES LESS THAN (738771) ENGINE = InnoDB,\n PARTITION p202209SUB04 VALUES LESS THAN (738773) ENGINE = InnoDB,\n PARTITION p202209SUB05 VALUES LESS THAN (738775) ENGINE = InnoDB,\n PARTITION p202209SUB06 VALUES LESS THAN (738777) ENGINE = InnoDB,\n PARTITION p202209SUB07 VALUES LESS THAN (738779) ENGINE = InnoDB,\n PARTITION p202209SUB08 VALUES LESS THAN (738781) ENGINE = InnoDB,\n PARTITION p202209SUB09 VALUES LESS THAN (738783) ENGINE = InnoDB,\n PARTITION p202209SUB10 VALUES LESS THAN (738785) ENGINE = InnoDB,\n PARTITION p202209SUB11 VALUES LESS THAN (738787) ENGINE = InnoDB,\n PARTITION p202209SUB12 VALUES LESS THAN (738789) ENGINE = InnoDB,\n PARTITION p202209SUB13 VALUES LESS THAN (738791) ENGINE = InnoDB,\n PARTITION p202209SUB14 VALUES LESS THAN (738793) ENGINE = InnoDB,\n PARTITION p202210SUB00 VALUES LESS THAN (738795) ENGINE = InnoDB,\n PARTITION p202210SUB01 VALUES LESS THAN (738797) ENGINE = InnoDB,\n PARTITION p202210SUB02 VALUES LESS THAN (738799) ENGINE = InnoDB,\n PARTITION p202210SUB03 VALUES LESS THAN (738801) ENGINE = InnoDB,\n PARTITION p202210SUB04 VALUES LESS THAN (738803) ENGINE = InnoDB,\n PARTITION p202210SUB05 VALUES LESS THAN (738805) ENGINE = InnoDB,\n PARTITION p202210SUB06 VALUES LESS THAN (738807) ENGINE = InnoDB,\n PARTITION p202210SUB07 VALUES LESS THAN (738809) ENGINE = InnoDB,\n PARTITION p202210SUB08 VALUES LESS THAN (738811) ENGINE = InnoDB,\n PARTITION p202210SUB09 VALUES LESS THAN (738813) ENGINE = InnoDB,\n PARTITION p202210SUB10 VALUES LESS THAN (738815) ENGINE = InnoDB,\n PARTITION p202210SUB11 VALUES LESS THAN (738817) ENGINE = InnoDB,\n PARTITION p202210SUB12 VALUES LESS THAN (738819) ENGINE = InnoDB,\n PARTITION p202210SUB13 VALUES LESS THAN (738821) ENGINE = InnoDB,\n PARTITION p202210SUB14 VALUES LESS THAN (738823) ENGINE = InnoDB,\n PARTITION p202211SUB00 VALUES LESS THAN (738826) ENGINE = InnoDB,\n PARTITION p202211SUB01 VALUES LESS THAN (738828) ENGINE = InnoDB,\n PARTITION p202211SUB02 VALUES LESS THAN (738830) ENGINE = InnoDB,\n PARTITION p202211SUB03 VALUES LESS THAN (738832) ENGINE = InnoDB,\n PARTITION p202211SUB04 VALUES LESS THAN (738834) ENGINE = InnoDB,\n PARTITION p202211SUB05 VALUES LESS THAN (738836) ENGINE = InnoDB,\n PARTITION p202211SUB06 VALUES LESS THAN (738838) ENGINE = InnoDB,\n PARTITION p202211SUB07 VALUES LESS THAN (738840) ENGINE = InnoDB,\n PARTITION p202211SUB08 VALUES LESS THAN (738842) ENGINE = InnoDB,\n PARTITION p202211SUB09 VALUES LESS THAN (738844) ENGINE = InnoDB,\n PARTITION p202211SUB10 VALUES LESS THAN (738846) ENGINE = InnoDB,\n PARTITION p202211SUB11 VALUES LESS THAN (738848) ENGINE = InnoDB,\n PARTITION p202211SUB12 VALUES LESS THAN (738850) ENGINE = InnoDB,\n PARTITION p202211SUB13 VALUES LESS THAN (738852) ENGINE = InnoDB,\n PARTITION p202211SUB14 VALUES LESS THAN (738854) ENGINE = InnoDB,\n PARTITION p202212SUB00 VALUES LESS THAN (738856) ENGINE = InnoDB,\n PARTITION p202212SUB01 VALUES LESS THAN (738858) ENGINE = InnoDB,\n PARTITION p202212SUB02 VALUES LESS THAN (738860) ENGINE = InnoDB,\n PARTITION p202212SUB03 VALUES LESS THAN (738862) ENGINE = InnoDB,\n PARTITION p202212SUB04 VALUES LESS THAN (738864) ENGINE = InnoDB,\n PARTITION p202212SUB05 VALUES LESS THAN (738866) ENGINE = InnoDB,\n PARTITION p202212SUB06 VALUES LESS THAN (738868) ENGINE = InnoDB,\n PARTITION p202212SUB07 VALUES LESS THAN (738870) ENGINE = InnoDB,\n PARTITION p202212SUB08 VALUES LESS THAN (738872) ENGINE = InnoDB,\n PARTITION p202212SUB09 VALUES LESS THAN (738874) ENGINE = InnoDB,\n PARTITION p202212SUB10 VALUES LESS THAN (738876) ENGINE = InnoDB,\n PARTITION p202212SUB11 VALUES LESS THAN (738878) ENGINE = InnoDB,\n PARTITION p202212SUB12 VALUES LESS THAN (738880) ENGINE = InnoDB,\n PARTITION p202212SUB13 VALUES LESS THAN (738882) ENGINE = InnoDB,\n PARTITION p202212SUB14 VALUES LESS THAN (738884) ENGINE = InnoDB) */", force: :cascade do |t|
    t.string "id", default: "", null: false
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "ip_address"
    t.integer "clicks"
    t.integer "conversions"
    t.datetime "recorded_at", default: "1970-01-01 00:00:00", null: false
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500
    t.string "status"
    t.integer "image_creative_id"
    t.datetime "converted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "vtm_host"
    t.string "vtm_page"
    t.string "vtm_channel"
    t.integer "mkt_site_id"
    t.integer "hits"
    t.integer "mkt_url_id"
    t.string "vtm_campaign"
    t.string "ip_country"
    t.string "approval"
    t.integer "order_id"
    t.string "step_name"
    t.string "step_label"
    t.string "true_conv_type"
    t.string "affiliate_conv_type"
    t.integer "lead_id"
    t.string "s1"
    t.string "s2"
    t.string "s3"
    t.string "s4"
    t.boolean "is_bot"
    t.integer "text_creative_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.string "keyword"
    t.integer "share_creative_id"
    t.datetime "captured_at"
    t.string "isp"
    t.string "browser"
    t.string "browser_version"
    t.string "device_type"
    t.string "device_brand"
    t.string "device_model"
    t.string "aff_uniq_id"
    t.string "ios_uniq"
    t.string "android_uniq"
    t.string "subid_4"
    t.string "subid_5"
    t.string "order_number"
    t.string "gaid"
    t.integer "email_creative_id"
    t.decimal "qscore", precision: 10, scale: 2
    t.string "ad_slot_id"
    t.integer "impression"
    t.datetime "published_at"
    t.json "forex"
    t.string "original_currency", limit: 3
    t.string "adv_uniq_id"
    t.decimal "order_total", precision: 20, scale: 2
    t.index ["adv_uniq_id"], name: "index_affiliate_stats_on_adv_uniq_id"
    t.index ["aff_uniq_id"], name: "index_affiliate_stats_on_aff_uniq_id"
    t.index ["affiliate_id"], name: "index_affiliate_stats_on_affiliate_id"
    t.index ["captured_at"], name: "index_affiliate_stats_on_captured_at"
    t.index ["converted_at"], name: "index_affiliate_stats_on_converted_at"
    t.index ["id"], name: "index_affiliate_stats_on_id"
    t.index ["ip_address"], name: "index_affiliate_stats_on_ip_address"
    t.index ["network_id", "captured_at"], name: "index_affiliate_stats_on_network_id_and_captured_at"
    t.index ["network_id"], name: "index_affiliate_stats_on_network_id"
    t.index ["offer_id"], name: "index_affiliate_stats_on_offer_id"
    t.index ["order_id"], name: "index_affiliate_stats_on_order_id"
    t.index ["published_at"], name: "index_affiliate_stats_on_published_at"
    t.index ["subid_1"], name: "index_affiliate_stats_on_subid_1"
    t.index ["subid_2"], name: "index_affiliate_stats_on_subid_2"
    t.index ["subid_3"], name: "index_affiliate_stats_on_subid_3"
    t.index ["subid_4"], name: "index_affiliate_stats_on_subid_4"
    t.index ["subid_5"], name: "index_affiliate_stats_on_subid_5"
    t.index ["updated_at"], name: "index_affiliate_stats_on_updated_at"
  end

  create_table "affiliate_tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "custom", default: false
    t.string "tag_type"
    t.integer "parent_category_id"
    t.index ["parent_category_id"], name: "index_affiliate_tags_on_parent_category_id"
  end

  create_table "affiliate_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "crypted_password"
    t.string "status"
    t.string "roles"
    t.string "unique_token"
    t.integer "time_zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "direct_phone"
    t.string "mobile_phone"
    t.string "fax"
    t.string "line"
    t.string "skype"
    t.string "avatar"
    t.string "title"
    t.string "wechat"
    t.string "qq"
    t.text "setup"
    t.integer "currency_id"
    t.string "avatar_cdn_url"
    t.bigint "language_id"
    t.boolean "tfa_enabled", default: false
    t.string "tfa_code", limit: 6
    t.index ["language_id"], name: "index_affiliate_users_on_language_id"
  end

  create_table "affiliates", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "crypted_password"
    t.string "status"
    t.string "unique_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "time_zone_id"
    t.boolean "email_verified", default: false
    t.integer "language_id"
    t.text "internal_notes"
    t.integer "referrer_id"
    t.integer "referral_count", default: 0
    t.text "extra"
    t.integer "experience_level"
    t.datetime "last_request_at"
    t.string "last_request_ip"
    t.date "birthday"
    t.string "ssn_ein"
    t.text "setup"
    t.integer "login_count", default: 0
    t.text "s2s_global_pixel"
    t.string "payment_term"
    t.integer "traffic_quality_level", default: 3
    t.decimal "current_balance", precision: 20, scale: 2
    t.string "business_entity"
    t.string "nickname"
    t.string "tax_filing_country"
    t.integer "ranking"
    t.integer "conversion_count"
    t.string "approval_method"
    t.datetime "referral_expired_at"
    t.integer "currency_id"
    t.datetime "ad_link_terms_accepted_at"
    t.integer "recruiter_id"
    t.string "facebook_id"
    t.string "facebook_email"
    t.string "ad_link_file"
    t.string "google_email"
    t.string "google_id"
    t.datetime "recruited_at"
    t.string "line_id"
    t.string "line_email"
    t.integer "channel_id"
    t.boolean "is_private", default: false
    t.integer "campaign_id"
    t.datetime "ad_link_activated_at"
    t.datetime "ad_link_installed_at"
    t.string "label"
    t.string "source", default: "Marketplace"
    t.string "gender"
    t.text "avatar_cdn_url"
    t.boolean "tfa_enabled", default: false
    t.string "tfa_code", limit: 6
    t.boolean "optout_from_offer_newsletter", default: false
    t.index ["facebook_email"], name: "index_affiliates_on_facebook_email"
    t.index ["facebook_id"], name: "index_affiliates_on_facebook_id"
    t.index ["google_email"], name: "index_affiliates_on_google_email"
    t.index ["google_id"], name: "index_affiliates_on_google_id"
    t.index ["referrer_id"], name: "index_affiliates_on_referrer_id"
    t.index ["updated_at"], name: "index_affiliates_on_updated_at"
  end

  create_table "alternative_domain_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "alternative_domain_id"
    t.date "date"
    t.integer "tracking_click_count", default: 0
    t.integer "tracking_usage_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alternative_domain_id"], name: "index_alternative_domain_stats_on_alternative_domain_id"
  end

  create_table "ap_tag_lines", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "orders"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ap_taggings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "ap_tag_line_id"
    t.boolean "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ap_tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.decimal "share", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "api_keys", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "status", default: "Active"
    t.text "value"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "partner_app_id"
    t.string "secret_key"
  end

  create_table "app_configs", charset: "utf8", force: :cascade do |t|
    t.string "role"
    t.text "profile_bg_url"
    t.text "logo_url"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attachments", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "owner_type"
    t.integer "owner_id"
    t.text "link", null: false
    t.integer "uploader_id"
    t.string "uploader_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "legacy", default: true
    t.index ["owner_id", "owner_type"], name: "index_attachments_on_owner_id_and_owner_type"
    t.index ["uploader_id", "uploader_type"], name: "index_attachments_on_uploader_id_and_uploader_type"
  end

  create_table "blog_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.string "status"
    t.datetime "posted_at"
    t.integer "blog_image_id"
    t.string "short_description"
    t.integer "author_id"
    t.string "author_type"
  end

  create_table "blog_images", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "image"
    t.integer "file_size"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "cdn_url"
  end

  create_table "blog_page_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "blog_page_id", null: false
    t.integer "blog_content_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_pages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "blog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.text "description"
  end

  create_table "blogs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "path"
    t.integer "skin_map_id"
  end

  create_table "bot_stats", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "ip_address"
    t.integer "clicks"
    t.integer "conversions"
    t.datetime "recorded_at", default: "1970-01-01 00:00:00", null: false
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500
    t.string "status"
    t.integer "image_creative_id"
    t.datetime "converted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "vtm_host"
    t.string "vtm_page"
    t.string "vtm_channel"
    t.integer "mkt_site_id"
    t.integer "hits"
    t.integer "mkt_url_id"
    t.string "vtm_campaign"
    t.string "ip_country"
    t.string "approval"
    t.integer "order_id"
    t.string "step_name"
    t.string "step_label"
    t.string "true_conv_type"
    t.string "affiliate_conv_type"
    t.integer "lead_id"
    t.string "s1"
    t.string "s2"
    t.string "s3"
    t.string "s4"
    t.boolean "is_bot", default: true
    t.integer "text_creative_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.string "keyword"
    t.integer "share_creative_id"
    t.datetime "captured_at"
    t.string "isp"
    t.string "browser"
    t.string "browser_version"
    t.string "device_type"
    t.string "device_brand"
    t.string "device_model"
    t.string "aff_uniq_id"
    t.string "ios_uniq"
    t.string "android_uniq"
    t.string "subid_4"
    t.string "subid_5"
    t.string "order_number"
    t.string "gaid"
    t.integer "email_creative_id"
    t.decimal "qscore", precision: 10, scale: 2
    t.string "ad_slot_id"
    t.integer "impression"
    t.datetime "published_at"
    t.json "forex"
    t.string "original_currency", limit: 3
    t.string "adv_uniq_id"
    t.decimal "order_total", precision: 20, scale: 2
    t.index ["adv_uniq_id"], name: "index_bot_stats_on_adv_uniq_id"
    t.index ["aff_uniq_id"], name: "index_bot_stats_on_aff_uniq_id"
    t.index ["affiliate_id"], name: "index_bot_stats_on_affiliate_id"
    t.index ["captured_at"], name: "index_bot_stats_on_captured_at"
    t.index ["converted_at"], name: "index_bot_stats_on_converted_at"
    t.index ["id"], name: "index_bot_stats_on_id"
    t.index ["ip_address"], name: "index_bot_stats_on_ip_address"
    t.index ["network_id", "captured_at"], name: "index_bot_stats_on_network_id_and_captured_at"
    t.index ["network_id"], name: "index_bot_stats_on_network_id"
    t.index ["offer_id"], name: "index_bot_stats_on_offer_id"
    t.index ["order_id"], name: "index_bot_stats_on_order_id"
    t.index ["published_at"], name: "index_bot_stats_on_published_at"
    t.index ["subid_1"], name: "index_bot_stats_on_subid_1"
    t.index ["subid_2"], name: "index_bot_stats_on_subid_2"
    t.index ["subid_3"], name: "index_bot_stats_on_subid_3"
    t.index ["subid_4"], name: "index_bot_stats_on_subid_4"
    t.index ["subid_5"], name: "index_bot_stats_on_subid_5"
    t.index ["updated_at"], name: "index_bot_stats_on_updated_at"
  end

  create_table "campaigns", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "notes", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "channel_id"
    t.string "campaign_type"
    t.text "destination_url"
  end

  create_table "categories", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "category_group_id"
  end

  create_table "category_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "click_pixels"
    t.boolean "has_ads", default: false
  end

  create_table "channels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "channel_type"
    t.text "notes", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "channel_group_id"
    t.text "website_url"
    t.string "contact_person"
    t.string "contact_email"
    t.string "contact_number"
    t.string "date_format"
    t.integer "time_zone_id"
    t.integer "ad_column_position"
    t.integer "date_column_position"
    t.integer "cost_column_position"
    t.integer "header_row_number"
    t.integer "footer_row_number"
    t.datetime "last_cost_upload_at"
    t.text "conversion_pixel"
    t.string "owner_type"
    t.integer "owner_id"
  end

  create_table "charges", charset: "utf8", force: :cascade do |t|
    t.bigint "network_id"
    t.bigint "credit_card_id"
    t.decimal "amount", precision: 10
    t.string "currency_code"
    t.string "status"
    t.boolean "is_captured"
    t.decimal "amount_captured", precision: 10
    t.boolean "is_refunded"
    t.decimal "amount_refunded", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "response"
    t.index ["credit_card_id"], name: "index_charges_on_credit_card_id"
    t.index ["network_id"], name: "index_charges_on_network_id"
  end

  create_table "chat_messages", charset: "utf8", force: :cascade do |t|
    t.bigint "chat_participation_id"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "cdn_urls"
    t.index ["chat_participation_id"], name: "index_chat_messages_on_chat_participation_id"
  end

  create_table "chat_participations", charset: "utf8", force: :cascade do |t|
    t.bigint "chat_room_id"
    t.string "participant_type"
    t.bigint "participant_id"
    t.string "participant_role", default: "participant"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chat_room_id"], name: "index_chat_participations_on_chat_room_id"
    t.index ["participant_type", "participant_id"], name: "index_chat_participations_on_participant"
  end

  create_table "chat_rooms", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uuid", default: "", null: false
  end

  create_table "chatbot_search_logs", charset: "utf8", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.text "keyword", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "language_id"
    t.index ["language_id"], name: "index_chatbot_search_logs_on_language_id"
    t.index ["owner_type", "owner_id"], name: "index_chatbot_search_logs_on_owner"
  end

  create_table "chatbot_steps", charset: "utf8", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.text "keywords", null: false
    t.string "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title", "content", "keywords"], name: "title", type: :fulltext
  end

  create_table "child_pixels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.string "key"
    t.string "value"
    t.text "pixel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ck_images", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "used_for"
  end

  create_table "click_abuse_reports", charset: "utf8", force: :cascade do |t|
    t.string "token", null: false
    t.text "raw_request"
    t.text "user_agent"
    t.string "ip_address"
    t.text "error_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "referer"
    t.integer "count", default: 0
    t.boolean "blocked", default: false
  end

  create_table "client_apis", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "host"
    t.text "path"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "api_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "column_settings"
    t.string "api_affiliate_id"
    t.string "auth_token"
    t.string "username"
    t.string "password"
    t.text "request_body_content"
    t.string "status", default: "Active"
    t.datetime "imported_at"
  end

  create_table "contact_lists", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "phone"
    t.boolean "email_optin", default: false
    t.string "status", default: "Active"
    t.text "notes"
    t.string "messenger_service"
    t.string "messenger_id"
  end

  create_table "conversion_steps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.decimal "true_share", precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "affiliate_share", precision: 8, scale: 2
    t.string "label"
    t.integer "days_to_return"
    t.string "true_conv_type", default: "CPL"
    t.string "affiliate_conv_type", default: "CPL"
    t.decimal "currency_multiplier", precision: 8, scale: 6, default: "1.0"
    t.integer "true_currency_id"
    t.integer "days_to_expire"
    t.string "conversion_mode"
    t.boolean "session_option", default: true
    t.string "on_past_due"
    t.decimal "first_level_commission_amount", precision: 20, scale: 2
    t.decimal "mid_level_commission_amount", precision: 20, scale: 2
    t.decimal "last_level_commission_amount", precision: 20, scale: 2
    t.decimal "first_level_commission_share", precision: 8, scale: 2
    t.decimal "mid_level_commission_share", precision: 8, scale: 2
    t.decimal "last_level_commission_share", precision: 8, scale: 2
    t.integer "offer_id"
    t.boolean "affiliate_pay_flexible", default: false
    t.decimal "max_affiliate_pay", precision: 20, scale: 2
    t.index ["offer_id"], name: "index_conversion_steps_on_offer_id"
    t.index ["updated_at"], name: "index_conversion_steps_on_updated_at"
  end

  create_table "countries", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "iso_2_country_code", limit: 2
    t.string "iso_3_country_code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
    t.integer "currency_id"
    t.string "continent"
  end

  create_table "creatives", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_variant_id"
    t.integer "entity_id"
    t.string "entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "entity_type"], name: "index_creatives_on_entity_id_and_entity_type"
    t.index ["entity_type"], name: "index_creatives_on_entity_type"
    t.index ["offer_variant_id", "entity_type"], name: "index_creatives_on_offer_variant_id_and_entity_type"
  end

  create_table "credit_cards", charset: "utf8", force: :cascade do |t|
    t.bigint "payment_gateway_id"
    t.string "unique_identifier"
    t.string "card_token"
    t.string "card_key"
    t.string "brand"
    t.string "last_4_digits"
    t.date "expire_at"
    t.boolean "default"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_gateway_id"], name: "index_credit_cards_on_payment_gateway_id"
    t.index ["unique_identifier", "payment_gateway_id"], name: "index_credit_cards_on_unique_identifier_and_payment_gateway_id", unique: true
  end

  create_table "crm_infos", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_log_id"
    t.integer "crm_target_id"
    t.string "crm_target_type"
    t.string "contact_media"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_snapshot"
  end

  create_table "currencies", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dot_one_delayed_jobs", charset: "utf8", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :long, null: false
    t.text "last_error", size: :long
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "owner_type"
    t.string "owner_id"
    t.integer "wl_company_id"
    t.string "job_type"
    t.string "locale"
    t.integer "user_id"
    t.string "user_type"
    t.string "currency_code", limit: 3
  end

  create_table "dotone_postbacks", primary_key: ["recorded_at", "id"], charset: "utf8mb4", force: :cascade do |t|
    t.integer "id", null: false, auto_increment: true
    t.string "postback_type"
    t.text "raw_response"
    t.text "raw_request"
    t.text "ip_address"
    t.string "affiliate_stat_id"
    t.datetime "recorded_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_stat_id"], name: "index_dotone_postbacks_on_affiliate_stat_id"
    t.index ["id"], name: "index_dotone_postbacks_on_id"
  end

  create_table "downloads", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "file"
    t.string "name"
    t.string "file_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.text "notes"
    t.text "exec_sql"
    t.text "headers"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "downloaded_by"
    t.text "extra_info"
    t.text "cdn_url"
  end

  create_table "easy_store_setups", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "network_id"
    t.string "store_name"
    t.string "store_title"
    t.string "store_domain"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language_id"
    t.string "time_zone_id"
    t.string "currency_id"
    t.string "email"
    t.integer "snippet_identifier"
    t.integer "order_update_webhook_identifier"
    t.integer "order_cancel_webhook_identifier"
    t.integer "order_delete_webhook_identifier"
    t.integer "offer_id"
  end

  create_table "email_opt_ins", charset: "utf8", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.integer "email_template_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "email_templates", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "email_type"
    t.string "subject"
    t.text "content"
    t.string "sender"
    t.string "recipient"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "footer"
  end

  create_table "event_has_category_groups", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "event_info_id"
    t.integer "category_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_infos", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "offer_id"
    t.string "event_type"
    t.integer "quota"
    t.decimal "value", precision: 20, scale: 2
    t.string "availability_type"
    t.text "item_links"
    t.text "keyword_requirements"
    t.boolean "is_affiliate_requirement_needed"
    t.integer "related_offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "event_requirements"
    t.text "details"
    t.text "instructions"
    t.string "coordinator_email"
    t.datetime "applied_by"
    t.datetime "selection_by"
    t.datetime "submission_by"
    t.datetime "evaluation_by"
    t.datetime "published_by"
    t.string "fulfillment_type"
    t.boolean "is_supplement_needed", default: false
    t.text "supplement_notes"
    t.text "event_contract"
    t.integer "popularity"
    t.string "popularity_unit"
    t.boolean "is_address_needed", default: false
    t.boolean "is_private_event", default: false
  end

  create_table "expertise_maps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "affiliate_prospect_id"
    t.integer "expertise_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["affiliate_id"], name: "index_expertise_maps_on_affiliate_id"
    t.index ["affiliate_prospect_id"], name: "index_expertise_maps_on_affiliate_prospect_id"
  end

  create_table "expertises", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_feeds", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "role"
    t.boolean "published", default: false
    t.integer "ordinal"
    t.datetime "created_at", precision: 6, null: false
    t.string "category"
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "image_creative_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "image_creative_id"
    t.integer "ui_download_count", default: 0
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_creative_id"], name: "index_image_creative_stats_on_image_creative_id"
  end

  create_table "image_creatives", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "size"
    t.string "image"
    t.integer "offer_variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "width"
    t.integer "height"
    t.integer "version"
    t.boolean "internal", default: false
    t.text "client_url"
    t.integer "file_size"
    t.datetime "active_date_start"
    t.datetime "active_date_end"
    t.boolean "is_infinity_time", default: true
    t.string "status"
    t.string "status_reason"
    t.string "locale"
    t.text "cdn_url"
    t.json "locales"
    t.index ["updated_at"], name: "index_image_creatives_on_updated_at"
  end

  create_table "images", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "owner_type"
    t.string "owner_id"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "asset"
    t.string "image_type"
    t.string "cdn_url"
    t.index ["owner_type", "owner_id"], name: "index_images_on_owner_type_and_owner_id"
  end

  create_table "job_status_checks", charset: "latin1", force: :cascade do |t|
    t.string "status"
    t.json "request_data"
    t.string "job_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "keyword_sets", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.text "keywords"
    t.string "owner_type"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "internal_keywords"
    t.index ["owner_id", "owner_type"], name: "index_keyword_sets_on_owner_id_and_owner_type"
  end

  create_table "languages", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lead_buyers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "filters"
    t.text "setup"
    t.integer "offer_id"
    t.decimal "price", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.boolean "lead_age_current", default: true
    t.integer "lead_age_number"
    t.string "lead_age_type"
    t.string "schedule_type"
    t.time "schedule_time"
    t.integer "spread"
  end

  create_table "lead_purchases", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "lead_buyer_id"
    t.integer "affiliate_lead_id"
    t.string "status"
    t.text "raw_request"
    t.text "raw_response"
    t.decimal "payout", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "network_id"
    t.integer "offer_id"
    t.integer "affiliate_id"
    t.index ["affiliate_id"], name: "index_lead_purchases_on_affiliate_id"
    t.index ["affiliate_lead_id"], name: "index_lead_purchases_on_affiliate_lead_id"
    t.index ["lead_buyer_id"], name: "index_lead_purchases_on_lead_buyer_id"
    t.index ["offer_id"], name: "index_lead_purchases_on_offer_id"
  end

  create_table "lead_score_infos", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "email_live"
    t.boolean "email_format"
    t.boolean "phone_format"
    t.text "social_live"
    t.string "name_live"
    t.string "city_live"
    t.string "state_live"
    t.integer "affiliate_lead_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "address_live"
    t.decimal "address_live_score", precision: 8, scale: 2
    t.decimal "email_live_score", precision: 8, scale: 2
    t.decimal "city_live_score", precision: 8, scale: 2
    t.decimal "state_live_score", precision: 8, scale: 2
    t.decimal "social_live_score", precision: 8, scale: 2
    t.decimal "name_live_score", precision: 8, scale: 2
    t.boolean "email_not_suppressed"
    t.decimal "email_format_score", precision: 4, scale: 2
    t.decimal "phone_format_score", precision: 4, scale: 2
    t.decimal "email_not_suppressed_score", precision: 4, scale: 2
    t.boolean "ip_not_blacklisted"
    t.decimal "ip_not_blacklisted_score", precision: 8, scale: 2
    t.string "unique_device_identifier"
    t.decimal "unique_device_identifier_score", precision: 8, scale: 2
  end

  create_table "missing_orders", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "offer_id"
    t.string "question_type"
    t.string "order_number"
    t.datetime "order_time"
    t.decimal "order_total", precision: 20, scale: 2
    t.string "payment_method"
    t.datetime "click_time"
    t.string "device"
    t.text "notes"
    t.string "status"
    t.integer "currency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "screenshot_cdn_url"
    t.string "status_summary"
    t.text "status_reason"
    t.integer "order_id"
    t.datetime "confirming_at"
    t.decimal "true_pay", precision: 10, scale: 2
    t.index ["affiliate_id"], name: "index_missing_orders_on_affiliate_id"
    t.index ["currency_id"], name: "index_missing_orders_on_currency_id"
    t.index ["offer_id"], name: "index_missing_orders_on_offer_id"
    t.index ["order_id"], name: "index_missing_orders_on_order_id"
  end

  create_table "mkt_sites", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "network_id"
    t.integer "offer_id"
    t.boolean "verified", default: false
    t.json "accepted_origins"
    t.string "platform"
  end

  create_table "mkt_urls", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "affiliate_id"
    t.text "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "revenue", precision: 20, scale: 2
  end

  create_table "networks", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "private_notes"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "universal_number"
    t.string "username"
    t.string "crypted_password"
    t.string "unique_token"
    t.integer "time_zone_id"
    t.string "status"
    t.string "address_1"
    t.integer "country_id"
    t.integer "language_id"
    t.text "setup"
    t.string "billing_name"
    t.string "billing_email"
    t.string "billing_phone_number"
    t.string "payment_term"
    t.integer "payment_term_days"
    t.datetime "published_date"
    t.text "ip_address_white_listed"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.text "dns_white_listed"
    t.text "blacklisted_referer_domain"
    t.text "redirect_url"
    t.text "secondary_contact_emails"
    t.text "blacklisted_subids"
    t.boolean "email_verified", default: false
    t.text "client_notes"
    t.string "contact_title"
    t.text "company_url"
    t.integer "currency_id"
    t.integer "billing_currency_id"
    t.decimal "sales_tax", precision: 4, scale: 2
    t.integer "recruiter_id"
    t.datetime "recruited_at"
    t.integer "partner_app_id"
    t.string "partner_app_token"
    t.datetime "active_at"
    t.integer "channel_id"
    t.string "persistence_token", default: "", null: false
    t.integer "campaign_id"
    t.datetime "profile_updated_at"
    t.datetime "note_updated_at"
    t.string "subscription", default: "Regular"
    t.string "billing_region"
    t.string "sales_pipeline"
    t.text "avatar_cdn_url"
    t.string "grade"
    t.json "brands"
    t.json "notification"
    t.boolean "tfa_enabled", default: false
    t.string "tfa_code", limit: 6
    t.index ["campaign_id"], name: "index_networks_on_campaign_id"
    t.index ["persistence_token"], name: "index_networks_on_persistence_token"
    t.index ["status"], name: "index_networks_on_status"
  end

  create_table "newsletters", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "sender"
    t.text "recipients"
    t.string "offer_list"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_sending_at"
    t.datetime "end_sending_at"
    t.integer "logo_id"
    t.text "error_reason"
    t.integer "sender_id"
    t.string "role"
    t.text "recipient"
    t.json "recipient_ids"
    t.index ["sender_id"], name: "index_newsletters_on_sender_id"
  end

  create_table "offer_caps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "number"
    t.string "cap_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "offer_variant_id"
    t.decimal "cap_notified_at", precision: 4, scale: 2
    t.datetime "earliest_at"
    t.integer "conversion_so_far"
  end

  create_table "offer_categories", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["offer_id"], name: "index_offer_categories_on_offer_id"
  end

  create_table "offer_conversion_pixels", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "offer_id"
    t.string "pixel_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offer_countries", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offer_products", id: false, charset: "utf8mb4", force: :cascade do |t|
    t.string "client_id_value", limit: 50
    t.string "universal_id_value"
    t.string "title"
    t.text "description_1", size: :medium
    t.text "description_2", size: :medium
    t.string "brand"
    t.string "category_1"
    t.string "category_2"
    t.string "category_3"
    t.text "product_url", size: :medium
    t.boolean "is_new"
    t.boolean "is_promotion"
    t.datetime "promo_start_at"
    t.datetime "promo_end_at"
    t.string "inventory_status"
    t.string "locale", limit: 5
    t.string "currency", limit: 3
    t.string "uniq_key", limit: 100
    t.integer "offer_id"
    t.json "prices"
    t.json "images"
    t.json "additional_attributes"
    t.integer "client_api_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_api_id"], name: "index_products_on_client_api_id"
    t.index ["client_id_value"], name: "index_products_on_client_id_value"
    t.index ["offer_id", "uniq_key"], name: "index_products_on_offer_id_and_uniq_key"
    t.index ["offer_id", "updated_at"], name: "index_products_on_offer_id_updated_at"
    t.index ["uniq_key"], name: "index_products_on_uniq_key", unique: true
  end

  create_table "offer_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "offer_id"
    t.date "date"
    t.integer "detail_view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch"
    t.index ["offer_id"], name: "index_offer_stats_on_offer_id"
  end

  create_table "offer_terms", id: false, charset: "utf8mb4", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "term_id"
    t.index ["offer_id", "term_id"], name: "index_offer_terms_on_offer_id_and_term_id", unique: true
  end

  create_table "offer_variants", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.string "name"
    t.text "description", size: :medium
    t.text "destination_url", size: :medium
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.boolean "is_default"
    t.string "step_label"
    t.boolean "can_config_url", default: false
    t.text "sku"
    t.text "deeplink_parameters"
    t.string "variant_client_id"
    t.integer "language_id"
    t.string "variant_type", default: "Home Page", null: false
    t.index ["is_default"], name: "index_offer_variants_on_is_default"
    t.index ["offer_id"], name: "index_offer_variants_on_offer_id"
    t.index ["updated_at"], name: "index_offer_variants_on_updated_at"
  end

  create_table "offers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "network_id"
    t.float "earning_meter"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "destination_url", size: :medium
    t.string "conversion_approval_mode", default: "Auto"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.text "country_names"
    t.text "category_names"
    t.text "lead_filters"
    t.boolean "need_approval", default: true
    t.text "approval_message"
    t.string "tracking_type", default: "Real Time"
    t.string "traffic_restriction_ids"
    t.string "cache_category_ids"
    t.text "cache_country_ids"
    t.text "private_notes"
    t.datetime "expired_at"
    t.boolean "no_expiration", default: true
    t.string "conversion_type"
    t.string "true_conv_type", default: "CPL"
    t.string "affiliate_conv_type", default: "CPL"
    t.text "brand_background"
    t.text "product_description"
    t.text "target_audience"
    t.text "suggested_media"
    t.text "other_info"
    t.datetime "published_date"
    t.text "custom_lead_download"
    t.string "short_description"
    t.string "new_tracking_type"
    t.integer "current_monthly_conversion"
    t.decimal "budget", precision: 20, scale: 2
    t.text "lead_attribute_options"
    t.string "pixel_installed"
    t.text "redirect_url"
    t.boolean "enforce_uniq_ip", default: false
    t.string "sparkline_data"
    t.decimal "epc", precision: 8, scale: 2
    t.string "client_uniq_id"
    t.text "api_import_todo"
    t.boolean "meta_refresh_redirect", default: false
    t.string "client_offer_name"
    t.string "package_name"
    t.integer "cache_days_to_expire", default: 0
    t.text "click_pixels"
    t.boolean "click_geo_filter", default: false
    t.string "approval_method"
    t.string "captured_time"
    t.string "approved_time"
    t.string "published_time"
    t.boolean "has_product_api", default: false
    t.json "translation_stat_cache"
    t.integer "captured_time_num_days"
    t.integer "published_time_num_days"
    t.integer "approved_time_num_days"
    t.string "attribution_type", default: "Last Click"
    t.string "track_device", default: "---\n- Desktop\n- Mobile Web\n"
    t.decimal "custom_epc", precision: 8, scale: 2
    t.text "manager_insight"
    t.string "conversion_point"
    t.text "affiliate_program_intro"
    t.datetime "suspended_at"
    t.boolean "mixed_affiliate_pay", default: false
    t.json "whitelisted_destination_urls"
    t.index ["network_id"], name: "index_offers_on_network_id"
    t.index ["type"], name: "index_offers_on_type"
    t.index ["updated_at"], name: "index_offers_on_updated_at"
  end

  create_table "optout_emails", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "offer_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "md5"
    t.index ["md5"], name: "index_optout_emails_on_md5"
  end

  create_table "orders", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "affiliate_id"
    t.string "order_number"
    t.decimal "total", precision: 20, scale: 2
    t.decimal "affiliate_share", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.decimal "true_share", precision: 20, scale: 2
    t.decimal "true_pay", precision: 20, scale: 2
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "affiliate_stat_id"
    t.string "step_name"
    t.string "conversion_type"
    t.boolean "has_clicks", default: false
    t.string "step_label"
    t.string "affiliate_conv_type"
    t.string "true_conv_type"
    t.datetime "converted_at"
    t.integer "network_id"
    t.decimal "original_true_pay", precision: 20, scale: 2
    t.decimal "original_total", precision: 20, scale: 2
    t.datetime "published_at"
    t.json "forex"
    t.string "original_currency", limit: 3
    t.index ["affiliate_stat_id"], name: "index_orders_on_affiliate_stat_id"
    t.index ["order_number"], name: "index_orders_on_order_number"
    t.index ["updated_at"], name: "index_orders_on_updated_at"
  end

  create_table "owner_has_tags", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.integer "affiliate_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order"
    t.string "access_type"
    t.index ["owner_id"], name: "index_owner_has_tags_on_owner_id"
    t.index ["owner_type", "owner_id", "affiliate_tag_id"], name: "index_owner_has_tags_unique", unique: true
    t.index ["owner_type"], name: "index_owner_has_tags_on_owner_type"
  end

  create_table "partner_apps", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.string "email_address"
    t.string "app_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility"
  end

  create_table "pay_schedules", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "true_share", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.decimal "affiliate_share", precision: 8, scale: 2
    t.boolean "expired", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expired_at"
    t.index ["owner_id", "owner_type"], name: "index_pay_schedules_on_owner_id_and_owner_type"
  end

  create_table "payment_fees", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_payment_id"
    t.string "label"
    t.decimal "amount", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["affiliate_payment_id"], name: "index_payment_fees_on_affiliate_payment_id"
  end

  create_table "payment_gateways", charset: "utf8", force: :cascade do |t|
    t.bigint "network_id"
    t.string "customer_token"
    t.integer "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_id"], name: "index_payment_gateways_on_network_id"
  end

  create_table "phone_verifications", charset: "utf8", force: :cascade do |t|
    t.string "phone_number", null: false
    t.string "otp"
    t.datetime "expired_at", null: false
    t.datetime "verified_at"
    t.integer "attempts", default: 0, null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expired_at"], name: "index_phone_verifications_on_expired_at"
    t.index ["owner_type", "owner_id", "phone_number"], name: "index_phone_verification_phone_number_unique_owner", unique: true
    t.index ["owner_type", "owner_id"], name: "index_phone_verifications_on_owner"
    t.index ["phone_number"], name: "index_phone_verifications_on_phone_number"
  end

  create_table "popup_feeds", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.string "button_label"
    t.text "cdn_url"
    t.string "url"
    t.boolean "published", default: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "postbacks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "postback_type"
    t.text "raw_response"
    t.text "raw_request"
    t.string "affiliate_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recorded_at"
    t.index ["affiliate_stat_id"], name: "index_postbacks_on_affiliate_stat_id"
  end

  create_table "prices", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "owner_id"
    t.string "owner_type"
    t.string "currency_code", limit: 3
    t.string "price_type"
    t.decimal "amount", precision: 20, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_prices_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id", "currency_code", "price_type"], name: "index_unique_bulk_insert_unique", unique: true
    t.index ["owner_type", "owner_id"], name: "index_prices_on_owner_type_and_owner_id"
  end

  create_table "product_categories", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "offer_id"
    t.string "locale", limit: 5
    t.index ["name", "offer_id"], name: "index_product_categories_on_name_and_offer_id"
    t.index ["offer_id", "locale", "name"], name: "index_unique_bulk_insert", unique: true
    t.index ["offer_id"], name: "index_product_categories_on_offer_id"
  end

  create_table "product_has_offers", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "offer_id"
    t.string "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_has_offers_on_product_id"
  end

  create_table "products", id: false, charset: "utf8mb4", options: "ENGINE=InnoDB\n/*!50100 PARTITION BY KEY (uniq_key)\nPARTITIONS 10 */", force: :cascade do |t|
    t.string "client_id_value", limit: 50
    t.string "universal_id_value"
    t.string "title"
    t.text "description_1", size: :medium
    t.text "description_2", size: :medium
    t.string "brand"
    t.string "category_1"
    t.string "category_2"
    t.string "category_3"
    t.text "product_url", size: :medium
    t.boolean "is_new"
    t.boolean "is_promotion"
    t.datetime "promo_start_at"
    t.datetime "promo_end_at"
    t.string "inventory_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", limit: 5
    t.string "currency", limit: 3
    t.string "uniq_key", limit: 100
    t.integer "offer_id"
    t.text "prices", size: :long
    t.text "images", size: :long
    t.text "additional_attributes", size: :long
    t.index ["client_id_value"], name: "index_products_on_client_id_value"
    t.index ["offer_id", "uniq_key"], name: "index_products_on_offer_id_and_uniq_key"
    t.index ["offer_id", "updated_at"], name: "index_products_on_offer_id_and_updated_at"
    t.index ["uniq_key"], name: "index_products_on_uniq_key", unique: true
  end

  create_table "publisher_prospects", charset: "latin1", force: :cascade do |t|
    t.string "email"
    t.integer "country_id"
    t.integer "affiliate_id"
    t.integer "recruiter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_publisher_prospects_on_affiliate_id"
    t.index ["country_id"], name: "index_publisher_prospects_on_country_id"
    t.index ["email"], name: "index_publisher_prospects_on_email", unique: true
    t.index ["recruiter_id"], name: "index_publisher_prospects_on_recruiter_id"
  end

  create_table "quicklinks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "link_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
  end

  create_table "shopify_setups", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "store_domain"
    t.string "access_token"
    t.string "scope"
    t.integer "network_id"
    t.integer "offer_id"
    t.string "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "script_tag_id"
    t.string "script_tag_file"
    t.string "order_update_webhook_id"
    t.string "order_delete_webhook_id"
    t.string "order_cancel_webhook_id"
  end

  create_table "site_info_category_groups", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "category_group_id"
    t.integer "site_info_id"
  end

  create_table "site_info_categories", charset: "latin1", force: :cascade do |t|
    t.integer "category_id"
    t.integer "site_info_id"
    t.index ["category_id"], name: "index_site_info_categories_on_category_id"
    t.index ["site_info_id"], name: "index_site_info_categories_on_site_info_id"
  end

  create_table "site_info_tags", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "site_info_id"
    t.integer "affiliate_tag_id"
  end

  create_table "site_infos", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url"
    t.text "description"
    t.text "comments"
    t.string "unique_visit_per_day"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "brand_domain_opt_outs"
    t.integer "affiliate_prospect_id"
    t.json "appearances"
    t.text "page_url_opt_outs"
    t.string "status", default: "Active"
    t.integer "followers_count"
    t.integer "media_count"
    t.datetime "last_media_posted_at"
    t.string "account_id"
    t.string "account_type"
    t.string "username"
    t.integer "unique_visit_per_month", default: 0
    t.text "access_token"
    t.boolean "verified", default: false
    t.text "error_details"
    t.datetime "metrics_last_updated_at"
    t.bigint "affiliate_id"
    t.boolean "ad_link_enabled", default: true
    t.boolean "verifiable", default: true
    t.index ["account_id", "account_type"], name: "index_site_infos_on_account_id_and_account_type"
    t.index ["account_id"], name: "index_site_infos_on_account_id"
    t.index ["affiliate_id"], name: "index_site_infos_on_affiliate_id"
  end

  create_table "snippets", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "snippet_key"
    t.text "snippet_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
  end

  create_table "stat_conversions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "stat_id"
    t.datetime "recorded_at"
    t.string "step_name"
    t.integer "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "conversion_type"
  end

  create_table "stat_postbacks", primary_key: ["recorded_at", "id"], charset: "utf8mb4", force: :cascade do |t|
    t.integer "id", null: false, auto_increment: true
    t.string "postback_type"
    t.text "raw_response"
    t.text "raw_request"
    t.string "affiliate_stat_id"
    t.datetime "recorded_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_stat_id"], name: "index_stat_postbacks_on_affiliate_stat_id"
    t.index ["id"], name: "index_stat_postbacks_on_id"
  end

  create_table "stat_score_infos", id: :integer, charset: "utf8", force: :cascade do |t|
    t.boolean "ip_not_blacklisted"
    t.string "affiliate_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "ip_not_blacklisted_score", precision: 8, scale: 2
    t.decimal "ip_ua_blacklist_score", precision: 8, scale: 2
    t.integer "ip_ua_blacklist_postback_count"
    t.string "unique_device_identifier"
    t.decimal "unique_device_identifier_score", precision: 10, scale: 2
    t.string "email_live"
    t.decimal "email_live_score", precision: 10, scale: 2
    t.string "email_not_suppressed"
    t.decimal "email_not_suppressed_score", precision: 10, scale: 2
    t.boolean "isp_not_blacklisted"
    t.decimal "isp_blacklist_score", precision: 8
    t.index ["affiliate_stat_id"], name: "index_stat_score_infos_on_affiliate_stat_id"
  end

  create_table "step_pixels", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "conversion_step_id"
    t.integer "affiliate_offer_id"
    t.text "conversion_pixel_html"
    t.text "conversion_pixel_s2s"
  end

  create_table "step_prices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_offer_id"
    t.integer "conversion_step_id"
    t.decimal "custom_amount", precision: 8, scale: 2
    t.decimal "custom_share", precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "payout_amount", precision: 20, scale: 2
    t.decimal "payout_share", precision: 8, scale: 2
    t.index ["affiliate_offer_id", "conversion_step_id"], name: "index_step_prices_on_affiliate_offer_id_and_conversion_step_id"
    t.index ["affiliate_offer_id"], name: "index_step_prices_on_affiliate_offer_id"
  end

  create_table "terms", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "text_creative_categories", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "text_creative_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_text_creative_categories_on_category_id"
    t.index ["text_creative_id"], name: "index_text_creative_categories_on_text_creative_id"
  end

  create_table "text_creatives", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "creative_name"
    t.text "content"
    t.integer "offer_variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "active_date_start"
    t.datetime "active_date_end"
    t.boolean "is_infinity_time", default: true
    t.string "title"
    t.string "status"
    t.string "status_reason"
    t.string "content_1"
    t.string "content_2"
    t.string "ad_unit_template"
    t.string "coupon_code"
    t.text "custom_landing_page"
    t.string "button_text"
    t.string "deal_scope", limit: 20
    t.string "locale"
    t.datetime "published_at"
    t.bigint "currency_id"
    t.json "locales"
    t.string "original_price"
    t.string "offer_name"
    t.string "discount_price"
    t.index ["currency_id"], name: "index_text_creatives_on_currency_id"
  end

  create_table "time_zones", charset: "utf8", force: :cascade do |t|
    t.string "gmt"
    t.string "name"
    t.string "gmt_string"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "traces", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "agent"
    t.string "agent_id"
    t.string "agent_type"
    t.string "verb"
    t.string "target"
    t.string "target_id"
    t.string "target_type"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_traces_on_agent_id"
    t.index ["agent_type"], name: "index_traces_on_agent_type"
    t.index ["created_at"], name: "index_traces_on_created_at"
    t.index ["target_id"], name: "index_traces_on_target_id"
    t.index ["target_type"], name: "index_traces_on_target_type"
    t.index ["verb"], name: "index_traces_on_verb"
  end

  create_table "translations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "locale"
    t.string "field"
    t.text "content"
    t.string "owner_type"
    t.string "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unique_id", limit: 64
    t.index ["content"], name: "full_text_idx", type: :fulltext
    t.index ["owner_id", "owner_type"], name: "index_translations_on_owner_id_and_owner_type"
    t.index ["unique_id"], name: "index_translations_on_unique_id", unique: true
  end

  create_table "unique_view_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "site_info_id"
    t.date "date"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch"
    t.bigint "affiliate_id"
    t.index ["affiliate_id"], name: "index_unique_view_stats_on_affiliate_id"
    t.index ["site_info_id", "date", "batch"], name: "index_unique_view_stats_on_site_info_id_and_date_and_batch"
  end

  create_table "uploads", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "file"
    t.text "descriptions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.string "owner_type"
    t.integer "owner_id"
    t.text "error_details"
    t.string "uploaded_by"
    t.text "cdn_url"
  end

  create_table "vtm_campaigns", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "affiliate_id"
  end

  create_table "vtm_channels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "affiliate_id"
    t.integer "network_id"
    t.integer "mkt_site_id"
    t.text "visit_pixel"
    t.text "conv_pixel"
    t.integer "offer_id"
  end

  create_table "vtm_pixels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "vtm_channel_id"
    t.string "step_name"
    t.text "order_conv_pixel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wla_relations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "member_id"
    t.integer "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
