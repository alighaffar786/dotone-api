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

ActiveRecord::Schema.define(version: 2024_12_18_041712) do

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

  create_table "ad_slot_category_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "ad_slot_id"
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

  create_table "ad_slots", id: :string, default: "", charset: "utf8", force: :cascade do |t|
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

  create_table "addresses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state_province"
    t.string "zip_code"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "advertiser_cats", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "network_id"
    t.integer "category_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["network_id"], name: "index_advertiser_cats_on_network_id"
  end

  create_table "advertiser_prospect_channels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "ad_channel_id"
    t.integer "advertiser_prospect_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertiser_prospects", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "company_name"
    t.string "company_legal_number"
    t.string "status"
    t.string "website"
    t.string "contact_person_name"
    t.string "contact_person_title"
    t.integer "contact_person_phone_id"
    t.string "contact_person_email"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "company_phone_number"
    t.string "contact_person_phone_number"
    t.integer "category_group_id"
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

  create_table "affiliate_feeds", id: :integer, charset: "utf8", force: :cascade do |t|
    t.text "content"
    t.datetime "published_at"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.boolean "sticky", default: false
    t.datetime "sticky_until"
  end

  create_table "affiliate_has_tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "affiliate_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_affiliate_has_tags_on_affiliate_id"
  end

  create_table "affiliate_lead_logs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_lead_id"
    t.string "note_type"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["affiliate_lead_id"], name: "index_affiliate_lead_logs_on_affiliate_lead_id"
  end

  create_table "affiliate_leads", primary_key: ["id", "stat_recorded_at"], charset: "utf8", force: :cascade do |t|
    t.integer "id", null: false, auto_increment: true
    t.string "unique_token"
    t.string "affiliate_stat_id"
    t.text "info"
    t.integer "offer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "ip_address"
    t.string "client_status"
    t.datetime "recorded_at"
    t.string "system_status"
    t.text "filtered_invalids"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.string "time_to_call"
    t.text "signup_url"
    t.string "via", limit: 10, default: "Web"
    t.integer "network_id"
    t.text "via_api_details"
    t.datetime "stat_recorded_at", default: "1970-01-01 00:00:00", null: false
    t.string "stat_approval"
    t.integer "affiliate_id"
    t.decimal "qscore", precision: 8, scale: 2
    t.string "crm_status"
    t.string "device_identifier"
    t.string "encrypted_password"
    t.datetime "stat_converted_at"
    t.integer "affiliate_user_id"
    t.string "stat_status"
    t.datetime "stat_published_at"
    t.integer "referrer_id"
    t.index ["affiliate_id"], name: "index_affiliate_leads_on_affiliate_id"
    t.index ["affiliate_stat_id"], name: "index_affiliate_leads_on_affiliate_stat_id"
    t.index ["device_identifier"], name: "index_affiliate_leads_on_device_identifier"
    t.index ["email"], name: "index_affiliate_leads_on_email"
    t.index ["offer_id"], name: "index_affiliate_leads_on_offer_id"
    t.index ["phone"], name: "index_affiliate_leads_on_phone"
    t.index ["recorded_at"], name: "index_affiliate_leads_on_recorded_at"
    t.index ["referrer_id"], name: "index_affiliate_leads_on_referrer_id"
    t.index ["unique_token"], name: "index_affiliate_leads_on_unique_token"
  end

  create_table "affiliate_logs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_id"
    t.string "note_type"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "agent_type"
    t.integer "agent_id"
  end

  create_table "affiliate_offers", id: :integer, charset: "utf8", force: :cascade do |t|
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
    t.index ["affiliate_id"], name: "index_affiliate_payments_on_affiliate_id"
    t.index ["paid_at"], name: "index_affiliate_payments_on_paid_at"
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

  create_table "affiliate_stat_captured_ats", primary_key: ["captured_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
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
    t.string "attribution_level"
    t.index ["affiliate_id"], name: "index_affiliate_stat_captured_ats_on_affiliate_id"
    t.index ["id"], name: "index_affiliate_stat_captured_ats_on_id"
    t.index ["network_id"], name: "index_affiliate_stat_captured_ats_on_network_id"
    t.index ["offer_id"], name: "index_affiliate_stat_captured_ats_on_offer_id"
    t.index ["updated_at"], name: "index_affiliate_stat_captured_ats_on_updated_at"
  end

  create_table "affiliate_stat_converted_ats", primary_key: ["converted_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
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
    t.string "attribution_level"
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

  create_table "affiliate_stat_published_ats", primary_key: ["published_at", "id"], charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
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
    t.string "attribution_level"
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

  create_table "affiliate_stats", primary_key: ["recorded_at", "id"], charset: "utf8", force: :cascade do |t|
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
    t.datetime "recorded_at", default: "1975-01-01 00:00:00", null: false
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
    t.string "attribution_level"
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

  create_table "alternative_domains", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "host"
    t.integer "wl_company_id"
    t.boolean "visible", default: true
    t.string "host_type"
    t.datetime "expired_at"
    t.string "status"
    t.string "hosted_zone_id"
    t.text "name_servers"
    t.string "certificate_arn"
    t.string "load_balancer_dns_name"
    t.text "listener_https_arn"
    t.text "listener_http_arn"
    t.text "target_group_arn"
    t.text "load_balancer_arn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "validation_record"
    t.boolean "adult_only", default: false
    t.boolean "migrated", default: false
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

  create_table "attachments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "owner_type"
    t.integer "owner_id"
    t.text "link", null: false
    t.integer "uploader_id"
    t.string "uploader_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_attachments_on_owner_id_and_owner_type"
    t.index ["uploader_id", "uploader_type"], name: "index_attachments_on_uploader_id_and_uploader_type"
  end

  create_table "blacklisted_isps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "isp_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isp_name"], name: "index_blacklisted_isps_on_isp_name"
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

  create_table "campaign_caps", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "affiliate_id"
    t.string "cap_type"
    t.integer "number"
    t.decimal "notified_at", precision: 4, scale: 2
    t.boolean "send_email_notification"
    t.integer "time_zone_id"
    t.string "redirect_mode", default: "Soft"
    t.datetime "earliest_checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id", "affiliate_id"], name: "index_campaign_caps_on_offer_id_and_affiliate_id"
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

  create_table "channel_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "child_pixels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.string "key"
    t.string "value"
    t.text "pixel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ck_images", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "used_for"
  end

  create_table "client_apis", id: :integer, charset: "utf8", force: :cascade do |t|
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
  end

  create_table "cms_authentications", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_categories", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "cms_domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "language_id"
    t.boolean "delta", default: true, null: false
    t.integer "parent_id"
  end

  create_table "cms_comments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_content_id"
    t.integer "cms_user_id"
    t.text "content"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_commissions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_user_id"
    t.integer "cms_content_id"
    t.string "commission_type"
    t.decimal "amount", precision: 20, scale: 2
    t.string "status"
    t.boolean "is_paid", default: false
    t.datetime "recorded_at"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_content_hits", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_content_id"
    t.integer "cms_user_id"
    t.string "ip_address"
    t.text "referer_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "promoted_by_id"
    t.boolean "count_cached", default: false
    t.index ["cms_user_id", "created_at"], name: "index_cms_content_hits_on_cms_user_id_and_created_at"
  end

  create_table "cms_content_images", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_content_id"
    t.string "size"
    t.string "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "posted_at"
    t.integer "user_id"
    t.integer "cms_sub_category_id"
    t.integer "cms_domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "language_id"
    t.boolean "delta", default: true, null: false
    t.text "buy_link"
    t.decimal "price", precision: 20, scale: 2
    t.text "image_order"
    t.string "source"
    t.decimal "max_price", precision: 20, scale: 2
    t.integer "parent_id"
    t.boolean "picture_only", default: false
    t.text "keywords"
    t.integer "cms_user_id"
    t.string "status", default: "Draft"
    t.text "secondary_link"
    t.string "meta_description"
    t.integer "base_counter"
    t.integer "view_count"
    t.integer "promoted_view_count"
  end

  create_table "cms_domains", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "default_language_id"
    t.boolean "delta", default: true, null: false
  end

  create_table "cms_extended_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_content_id"
    t.string "key"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_payments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_user_id"
    t.datetime "billing_start_at"
    t.datetime "billing_end_at"
    t.datetime "paid_at"
    t.decimal "base_commission", precision: 20, scale: 2
    t.decimal "extra_commission", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_sub_categories", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "cms_category_id"
    t.integer "user_id"
    t.integer "cms_domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "language_id"
    t.boolean "delta", default: true, null: false
    t.integer "parent_id"
  end

  create_table "cms_user_extensions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_user_id"
    t.string "key"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_user_images", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_user_id"
    t.string "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "cms_domain_id"
    t.string "username"
    t.string "crypted_password"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.string "unique_token"
    t.string "first_name"
    t.string "last_name"
    t.boolean "is_editor", default: false
    t.integer "editor_payment_language_id"
    t.string "editor_payment_type"
    t.boolean "is_contributor", default: false
    t.string "alias_name"
    t.string "vanity_name"
    t.integer "time_zone_id"
  end

  create_table "colleague_links", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "colleague_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_lists", id: :integer, charset: "utf8", force: :cascade do |t|
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
  end

  create_table "contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "language_id"
    t.string "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.datetime "expiration_date"
  end

  create_table "conversion_requirements", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "language_id"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversion_steps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
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

  create_table "crm_infos", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_log_id"
    t.integer "crm_target_id"
    t.string "crm_target_type"
    t.string "contact_media"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_snapshot"
  end

  create_table "currencies", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", size: :long
    t.text "last_error", size: :long, collation: "latin1_swedish_ci"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", collation: "latin1_swedish_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue", collation: "latin1_swedish_ci"
    t.string "owner_type", collation: "latin1_swedish_ci"
    t.string "owner_id"
    t.integer "wl_company_id"
    t.string "job_type", collation: "latin1_swedish_ci"
    t.string "locale"
    t.integer "user_id"
    t.string "user_type"
    t.string "currency_code", limit: 3
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "direct_relationships", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "language_id"
    t.string "time_zone_id"
    t.string "currency_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "snippet_identifier"
    t.integer "order_update_webhook_identifier"
    t.integer "order_cancel_webhook_identifier"
    t.integer "order_delete_webhook_identifier"
    t.integer "offer_id"
  end

  create_table "email_suppressions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_email_suppressions_on_email", unique: true
  end

  create_table "email_templates", id: :integer, charset: "utf8", force: :cascade do |t|
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
    t.text "instructions"
    t.text "event_requirements"
    t.text "details"
    t.boolean "is_affiliate_requirement_needed"
    t.integer "related_offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "impression_stats", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.integer "language_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "impression_stats_1", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_2", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3386", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3389", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3390", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3393", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3396", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "impression_stats_3397", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "image_creative_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "language_id"
    t.string "id"
  end

  create_table "invoice_items", id: :integer, charset: "utf8", force: :cascade do |t|
    t.decimal "quantity", precision: 20, scale: 10
    t.string "description"
    t.decimal "unit_price", precision: 20, scale: 10
    t.decimal "total", precision: 20, scale: 10
    t.integer "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "status"
    t.integer "month"
    t.integer "year"
    t.integer "wl_company_id"
    t.decimal "total", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "wepay_checkout_id"
    t.text "wepay_raw_response"
    t.integer "plan_id"
    t.string "file"
  end

  create_table "ip_blacklists", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "ip_address"
    t.string "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ip_address"], name: "index_ip_blacklists_on_ip_address", unique: true
  end

  create_table "ip_ua_blacklists", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "ip"
    t.string "user_agent"
    t.integer "incoming_postback_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ip", "user_agent"], name: "index_ip_ua_blacklists_on_ip_and_user_agent", unique: true
  end

  create_table "job_companies", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
  end

  create_table "job_posts", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "url"
    t.datetime "posted_at"
    t.string "status"
    t.integer "job_company_id"
    t.string "submitted_by_email"
    t.integer "zip_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location"
    t.string "company_name"
    t.boolean "delta", default: true, null: false
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

  create_table "landing_pages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "destination_url", size: :medium
    t.integer "user_id"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sub_page_order"
    t.boolean "is_analytic_active", default: false
  end

  create_table "languages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "ts_code"
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

  create_table "media_usages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "month"
    t.integer "year"
    t.integer "wl_company_id"
    t.bigint "size"
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
    t.string "status_summary"
    t.text "status_reason"
    t.integer "order_id"
    t.datetime "confirming_at"
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
  end

  create_table "mkt_urls", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "affiliate_id"
    t.text "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "revenue", precision: 20, scale: 2
  end

  create_table "mobile_user_agents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "device_id"
    t.string "ua"
    t.text "extra_info"
    t.string "fall_back"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "name_blacklists", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_name_blacklists_on_name"
  end

  create_table "networks", id: :integer, charset: "utf8", force: :cascade do |t|
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
  end

  create_table "offer_approvals", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "user_id"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "publisher_traffic_type"
    t.text "publisher_traffic_notes"
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

  create_table "offer_placements", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "sub_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "key"
    t.text "notes", size: :medium
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
    t.integer "language_id"
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
    t.index ["is_default"], name: "index_offer_variants_on_is_default"
    t.index ["offer_id"], name: "index_offer_variants_on_offer_id"
    t.index ["updated_at"], name: "index_offer_variants_on_updated_at"
  end

  create_table "offers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "network_id"
    t.integer "earning_meter"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "destination_url", size: :medium
    t.string "conversion_approval_mode", default: "Auto"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "conversion_requirement_id"
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
    t.text "lead_score_setup"
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
    t.string "published_time"
    t.string "approved_time"
    t.boolean "has_product_api", default: false
    t.json "translation_stat_cache"
    t.integer "captured_time_num_days"
    t.integer "published_time_num_days"
    t.integer "approved_time_num_days"
    t.string "attribution_type", default: "Last Click"
    t.string "track_device", default: "---\n- Desktop\n"
    t.decimal "custom_epc", precision: 8, scale: 2
    t.text "manager_insight"
    t.string "conversion_point"
    t.text "affiliate_program_intro"
    t.index ["network_id"], name: "index_offers_on_network_id"
    t.index ["type"], name: "index_offers_on_type"
    t.index ["updated_at"], name: "index_offers_on_updated_at"
  end

  create_table "optout_emails", id: :integer, charset: "utf8", force: :cascade do |t|
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

  create_table "phones", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "country_code"
    t.string "area_code"
    t.string "prefix"
    t.string "line_number"
    t.string "extension"
    t.string "unit_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "max_event_volume"
    t.decimal "overage_price", precision: 20, scale: 2
    t.decimal "base_price", precision: 20, scale: 2
    t.decimal "media_usage_price_per_gb", precision: 20, scale: 2
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

  create_table "press_releases", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "posted_at"
    t.string "title"
    t.text "content", size: :medium
    t.string "status"
    t.integer "language_id"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "product_categories", id: :integer, charset: "utf8", force: :cascade do |t|
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

  create_table "products", id: false, charset: "utf8mb4", force: :cascade do |t|
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

  create_table "quicklinks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "link_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
  end

  create_table "roles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
  end

  create_table "sc_auto_ships", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "lg_lead_id"
    t.integer "day_period"
    t.integer "sc_subscription_id"
    t.integer "language_id"
    t.integer "sc_product_variant_id"
    t.datetime "next_order_at"
    t.decimal "unit_price", precision: 20, scale: 2
    t.integer "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "Active"
    t.integer "next_iteration", default: 1
  end

  create_table "sc_coupons", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_promotion_id"
    t.string "code"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_delivery_methods", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_delivery_prices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_delivery_method_id"
    t.decimal "shipping_price", precision: 10, scale: 2
    t.integer "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
  end

  create_table "sc_inventories", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "language_id"
    t.integer "sc_product_variant_id"
    t.decimal "cost_price", precision: 20, scale: 2
    t.decimal "msrp_price", precision: 20, scale: 2
    t.decimal "sell_price", precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "trial_period"
    t.decimal "trial_price", precision: 20, scale: 2
  end

  create_table "sc_inventory_compositions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_inventory_id"
    t.integer "sc_supply_item_id"
    t.integer "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_order_deliveries", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.integer "sc_order_status_id"
    t.string "via"
    t.string "tracking_number"
    t.datetime "shipped_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "receipt_number"
  end

  create_table "sc_order_items", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.integer "sc_inventory_id"
    t.integer "quantity"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sc_auto_ship_id"
    t.string "name"
    t.integer "sc_order_trial_id"
  end

  create_table "sc_order_payments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.string "status"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "gateway"
    t.text "gateway_request"
    t.text "gateway_response"
    t.string "gateway_status"
    t.string "gateway_summary"
    t.string "gateway_authorization_code"
    t.string "payment_type"
    t.decimal "amount", precision: 20, scale: 2
  end

  create_table "sc_order_price_adjustments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.string "title"
    t.decimal "amount", precision: 20, scale: 2
    t.integer "multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_order_promotions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.integer "sc_promotion_id"
    t.string "discount_summary"
    t.string "discount_type"
    t.decimal "discount_value", precision: 10
    t.decimal "discount_amount", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "coupon_code"
  end

  create_table "sc_order_statuses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_order_id"
    t.string "status"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_order_trials", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "lg_lead_id"
    t.integer "trial_period"
    t.decimal "trial_price", precision: 20, scale: 2
    t.integer "language_id"
    t.datetime "trial_end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "end_trial_price", precision: 20, scale: 2
    t.decimal "regular_price", precision: 20, scale: 2
    t.string "status"
  end

  create_table "sc_orders", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "lg_lead_id"
    t.datetime "ordered_at"
    t.integer "language_id"
    t.string "status"
    t.integer "sc_delivery_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "delivery_price", precision: 20, scale: 2
    t.string "unique_token"
    t.string "customer_email"
    t.string "customer_name"
    t.string "order_number"
    t.text "customer_notes"
    t.integer "iteration", default: 0
    t.boolean "has_subscription", default: false
  end

  create_table "sc_product_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_product_id"
    t.integer "language_id"
    t.text "description"
    t.text "disclaimer"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
  end

  create_table "sc_product_variant_contents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_product_variant_id"
    t.integer "language_id"
    t.text "disclaimer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.string "name"
  end

  create_table "sc_product_variant_specs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_product_variant_id"
    t.integer "sc_variant_type_id"
    t.string "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_product_variants", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "status"
    t.integer "sc_product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "subscription_based", default: false
    t.string "item_number"
    t.boolean "trial_based", default: false
  end

  create_table "sc_products", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.boolean "delta", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "item_number"
    t.integer "user_id"
  end

  create_table "sc_promo_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_promo_specs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_inventory_id"
    t.integer "sc_promo_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_promotions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.decimal "static_discount", precision: 20, scale: 2
    t.decimal "percentage_discount", precision: 20, scale: 2
    t.decimal "fixed_discount", precision: 20, scale: 2
    t.boolean "free_delivery", default: false
    t.integer "sc_promo_group_id"
    t.integer "promo_inventory_count"
    t.integer "required_sc_promo_group_id"
    t.integer "required_inventory_count"
    t.decimal "required_price", precision: 20, scale: 2
    t.boolean "required_first_time_customer", default: true
    t.boolean "required_one_per_customer", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "language_id"
  end

  create_table "sc_subscriptions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "language_id"
    t.integer "sc_product_variant_id"
    t.integer "day_period"
    t.text "disclaimer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sc_delivery_method_id"
  end

  create_table "sc_suppliers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_supply_items", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "sc_supplier_id"
    t.integer "quantity"
    t.string "item_number"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_variant_types", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "token"
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

  create_table "site_info_tags", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "site_info_id"
    t.integer "affiliate_tag_id"
  end

  create_table "site_infos", id: :integer, charset: "utf8", force: :cascade do |t|
    t.text "url"
    t.text "description"
    t.text "comments"
    t.string "unique_visit_per_day"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "brand_domain_opt_outs"
    t.text "page_url_opt_outs"
    t.string "status", default: "Active"
  end

  create_table "skin_maps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "wl_company_id"
    t.string "hostname"
    t.string "folder"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contact_email"
    t.boolean "https", default: false
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

  create_table "stats", id: false, charset: "utf8", force: :cascade do |t|
    t.string "id"
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
    t.datetime "recorded_at"
    t.decimal "true_pay", precision: 20, scale: 2
    t.decimal "affiliate_pay", precision: 20, scale: 2
    t.integer "affiliate_offer_id"
    t.string "manual_notes", limit: 500
    t.string "status"
    t.boolean "approved", default: true
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
    t.integer "text_creative_id"
    t.boolean "is_bot"
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
    t.decimal "custom_amount", precision: 20, scale: 2
    t.decimal "custom_share", precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "payout_amount", precision: 20, scale: 2
    t.decimal "payout_share", precision: 8, scale: 2
    t.index ["affiliate_offer_id", "conversion_step_id"], name: "index_step_prices_on_affiliate_offer_id_and_conversion_step_id"
    t.index ["affiliate_offer_id"], name: "index_step_prices_on_affiliate_offer_id"
  end

  create_table "sub_pages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "landing_page_id"
    t.text "destination_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_file_uploads", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "file_name"
    t.string "file_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_logos", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "wl_company_id"
    t.string "system_logo_type"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wl_company_id"], name: "index_system_logos_on_wl_company_id"
  end

  create_table "taggings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "text_creatives", id: :integer, charset: "utf8", force: :cascade do |t|
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
    t.string "custom_landing_page"
    t.string "button_text"
    t.string "deal_scope", limit: 20
    t.string "locale"
    t.datetime "published_at"
  end

  create_table "time_zones", id: :integer, charset: "utf8", force: :cascade do |t|
    t.decimal "gmt", precision: 8, scale: 2
    t.string "name"
    t.string "gmt_string"
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

  create_table "track_costs", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "product_source_id"
    t.integer "product_offer_id"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.datetime "recorded_at"
    t.decimal "cost", precision: 20, scale: 2
    t.integer "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "track_stats", id: false, charset: "utf8", force: :cascade do |t|
    t.string "id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "product_source_id"
    t.integer "product_offer_id"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "currency_id"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "ip_address"
    t.integer "clicks"
    t.integer "browses"
    t.integer "conversions"
    t.datetime "recorded_at"
    t.decimal "revenue", precision: 20, scale: 2
    t.decimal "cost", precision: 20, scale: 2
    t.string "platform"
    t.string "browser"
    t.string "version"
    t.string "os"
    t.boolean "ad_derived", default: false
  end

  create_table "traffic_stats", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "user_id"
    t.integer "clicks"
    t.integer "conversions"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_2", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3386", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3389", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3390", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3393", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3396", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3397", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3398", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "traffic_stats_3399", id: false, charset: "utf8", force: :cascade do |t|
    t.datetime "recorded_at"
    t.integer "clicks"
    t.integer "conversions"
    t.boolean "is_invalid", default: false
    t.string "invalid_reason"
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.decimal "true_pay", precision: 8, scale: 2
    t.decimal "affiliate_pay", precision: 8, scale: 2
    t.integer "language_id"
    t.integer "channel_id"
    t.integer "campaign_id"
    t.integer "ad_group_id"
    t.integer "ad_id"
    t.integer "landing_page_id"
    t.integer "offer_placement_id"
    t.string "ip_address"
    t.string "http_user_agent"
    t.string "http_referer"
    t.string "subid_1"
    t.string "subid_2"
    t.string "subid_3"
    t.integer "rescue_path_id"
    t.string "rescue_type"
    t.text "rescue_info"
    t.string "id"
    t.string "parent_id"
    t.boolean "included_in_traffic_stats", default: false
    t.integer "main_traffic_stat_id"
    t.integer "channel_group_id"
    t.integer "network_id"
    t.integer "sub_page_id"
    t.integer "image_creative_id"
  end

  create_table "transactions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "wl_company_id"
    t.string "status", default: "New"
    t.float "amount"
    t.string "credit_card_id"
    t.datetime "charged_at"
    t.text "raw_response"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.index ["owner_id", "owner_type"], name: "index_translations_on_owner_id_and_owner_type"
    t.index ["unique_id"], name: "index_translations_on_unique_id", unique: true
  end

  create_table "trials", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "wl_company_id"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cancel_at"
    t.string "lead_unique_token"
  end

  create_table "unique_view_stats", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "site_info_id"
    t.date "date"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch"
    t.index ["site_info_id", "date", "batch"], name: "index_unique_view_stats_on_site_info_id_and_date_and_batch"
  end

  create_table "upcoming_events", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "description", size: :medium
    t.string "location"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
    t.integer "language_id"
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

  create_table "user_activity_logs", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.string "target_type"
    t.string "verb"
    t.text "from_state"
    t.text "to_state"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
  end

  create_table "user_pixels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "offer_variant_id"
    t.integer "user_id"
    t.text "content"
    t.string "notes"
    t.string "pixel_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username"
    t.string "crypted_password"
    t.string "password_salt"
    t.string "persistence_token"
    t.string "single_access_token"
    t.string "perishable_token"
    t.integer "login_count", default: 0
    t.integer "failed_login_count", default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip"
    t.string "last_login_ip"
    t.boolean "active", default: false
    t.string "phone"
    t.integer "time_zone_id"
    t.string "login_domain"
    t.text "setup"
    t.string "avatar"
    t.integer "currency_id"
  end

  create_table "variant_tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "affiliate_tag_id"
    t.integer "offer_variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_type"
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

  create_table "wl_companies", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "domain_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "language_id"
    t.integer "user_id"
    t.string "label_type"
    t.string "tracking_domain"
    t.integer "currency_id"
    t.string "affiliate_domain_name"
    t.string "advertiser_domain_name"
    t.string "owner_domain_name"
    t.text "setup"
    t.string "general_contact_email"
    t.string "affiliate_contact_email"
    t.string "wepay_credit_card_id"
    t.text "address"
    t.string "account_type"
    t.text "logo_url"
    t.integer "plan_id"
    t.string "db_connection_name"
    t.string "api_domain_name"
    t.text "favicon_url"
    t.string "kinesis_sequence_number"
    t.string "geo", default: "US"
    t.string "s3_folder_name"
    t.string "billing_email"
    t.text "affiliate_terms"
  end

  create_table "wla_relations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "member_id"
    t.integer "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zip_codes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "code"
    t.string "latitude"
    t.string "longitude"
    t.string "city"
    t.string "state"
    t.string "county"
    t.string "zip_class"
  end

end
