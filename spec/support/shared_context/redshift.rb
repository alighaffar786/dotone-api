RSpec.shared_context 'with Stats' do
  before do
    ActiveRecord::Base.connection.drop_table :stats, if_exists: true
    ActiveRecord::Base.connection.create_table :stats
    [[:network_id, :integer], [:offer_id, :integer], [:offer_variant_id, :integer],
      [:affiliate_id, :integer], [:subid_1, :string], [:subid_2, :string], [:subid_3, :string],
      [:language_id, :integer], [:http_user_agent, :string], [:http_referer, :string], [:ip_address, :string],
      [:clicks, :integer], [:conversions, :integer], [:recorded_at, :datetime], [:true_pay, :decimal],
      [:affiliate_pay, :decimal], [:affiliate_offer_id, :integer], [:manual_notes, :string], [:status, :string],
      [:approved, :integer], [:image_creative_id, :integer], [:converted_at, :datetime], [:created_at, :datetime],
      [:updated_at, :datetime], [:vtm_page, :string], [:vtm_channel, :string], [:vtm_host, :string],
      [:mkt_site_id, :integer], [:hits, :integer], [:mkt_url_id, :integer], [:vtm_campaign, :string],
      [:ip_country, :string], [:approval, :string], [:order_id, :integer], [:step_name, :string],
      [:step_label, :string], [:true_conv_type, :string], [:affiliate_conv_type, :string], [:lead_id, :integer],
      [:s1, :string], [:s2, :string], [:s3, :string], [:s4, :string], [:is_bot, :boolean],
      [:text_creative_id, :integer], [:channel_id, :integer], [:campaign_id, :integer], [:ad_group_id, :integer],
      [:ad_id, :integer], [:keyword, :string], [:share_creative_id, :integer], [:captured_at, :datetime],
      [:isp, :string], [:browser, :string], [:browser_version, :string], [:device_type, :string],
      [:device_brand, :string], [:device_model, :string], [:aff_uniq_id, :string], [:ios_uniq, :string],
      [:android_uniq, :string], [:subid_4, :string], [:subid_5, :string], [:order_number, :string], [:gaid, :string],
      [:email_creative_id, :integer], [:qscore, :decimal], [:ad_slot_id, :string], [:impression, :integer],
      [:published_at, :datetime], [:adv_uniq_id, :string], [:forex, :string],
      [:original_currency, :string]].each do |name, type|
        ActiveRecord::Base.connection.add_column :stats, name, type
      end
  end
end
