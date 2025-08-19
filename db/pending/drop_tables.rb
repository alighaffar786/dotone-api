class DropTables < ActiveRecord::Migration[6.1]
  def change
    site_info_migration

    [
      :affiliate_traffic_types,
      :site_traffic_types,
      :cps_offer_setups,
      :traffic_types,
      :affiliate_feed_tags,
      :advertiser_prospects,
      :advertiser_prospect_channels,
      :affiliate_has_tags,
      :affiliate_prospects,
      :affiliate_prospect_interests,
      :api_pay_loads,
      :affiliate_leads,
      :affiliate_lead_logs,
      :conversion_requirements,
      :dot_one_delayed_jobs,
      :lead_buyers,
      :lead_purchases,
      :lead_score_infos,
      :site_info_category_groups,
      :affiliate_sites,
      :affiliate_cats,
      :variant_tags,
      :products,
      :email_creatives,
      :share_creatives,
      :mkt_urls,
      :ads,
      :ad_groups,
      :ad_tags,
      :ad_channels,
      :product_has_offers,
      :ap_tag_lines,
      :ap_taggings,
      :ap_tags,
      :optout_emails,
    ].each do |table_name|
      drop_table table_name, if_exists: true
    end

    rename_table :publisher_prospects, :affiliate_prospects

    [
      [:crm_infos, :target_snapshot],
      [:offer_variants, :language_id],
      [:networks, :persistence_token],
      [:category_groups, :has_ads],
      [:networks, :email_verified],
      [:affiliate_users, :avatar],
      [:offers, :lead_score_setup],
      [:offers, :lead_filters],
      [:offers, :custom_lead_download],
      [:offers, :conversion_requirement_id],
      [:networks, :notification_status],
      [:networks, :notification_interval],
      [:affiliates, :wl_company_id],
      [:affiliate_payment_infos, :affiliate_address_id],
      [:client_apis, :related_offer_ids],
      [:translations, :unique_id],
      [:wl_companies, :logo_url],
    ].each do |table_name, column_name|
      remove_column table_name, column_name, if_exists: true
    end

    AffiliateTag.where(name: ['Affiliate FAQ', 'Advertiser FAQ']).each do |tag|
      AffiliateFeed.where(id: OwnerHasTag.where(affiliate_tag_id: tag.id, owner_type: 'AffiliateFeed').select(:owner_id)).destroy_all
      tag.destroy
    end

    AffiliateTag.where(tag_type: ['Feed Role', 'Feed Type', 'Advertiser Contact Status', 'Affiliate Contact Status']).destroy_all
    AffiliateTag.where(name: ['New Offer', 'Top Offer', '300x250 Offer Slot']).destroy_all

    AffiliateTag.where(custom: true).destroy_all

    ClientApi.product_api.where(owner_type: 'Network').destroy_all

    AffHash.where(entity_type: ['AffiliateUser', 'Network', 'User', 'TextCreative']).count

    EmailTemplate.unscoped.where(owner_type: 'Offer').destroy_all

    OwnerHasTag.joins(:media_category).where(owner_type: 'Affiliate').destroy_all
  end

  def site_info_migration
    SiteInfo.where(status: 'Deleted').destroy_all

    remove_column :site_infos, :status, if_exists: true
  end
end
