class DotOne::AffiliateStats::Recorder
  def self.insert_stat(**args)
    sql = <<-SQL.squish
      INSERT INTO affiliate_stats (#{args.keys.join(', ')})
      VALUES (#{args.keys.map { '?' }.join(', ')})
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql([sql].concat(args.values))
    AffiliateStat.connection.execute(sanitized_sql)
  end

  def self.geo(ip_address)
    GEO_DB.lookup(ip_address)
  rescue StandardError
  end

  # NOTE:: OfferVariant is not being passed at all
  def self.record_hits(*args)
    return if args.length < 2

    tracking_token, tracking_data = args

    ### AFFILIATE ###
    return unless (affiliate = Affiliate.cached_find(tracking_token.affiliate_id))

    ### AFFILIATE OFFER ###
    affiliate_offer = AffiliateOffer.best_match(affiliate, offer_variant&.cached_offer)

    ip_address = tracking_data[:ip_address]
    tracking_id = DotOne::Utils.generate_token
    geo_ip = geo(ip_address)

    insert_stat(
      hits: 1,
      id: tracking_id,
      ip_address: ip_address,
      ip_country: geo_ip&.country&.name,

      affiliate_id: affiliate_offer&.affiliate_id || tracking_token.affiliate_id,
      affiliate_offer_id: affiliate_offer&.id,
      affiliate_pay: affiliate_offer&.custom_comission || offer_variant&.affiliate_pay,

      language_id: offer_variant&.language_id,
      network_id: offer_variant&.cached_offer&.network_id,
      offer_id: offer_variant&.offer_id,
      offer_variant_id: offer_variant&.id,
      true_pay: offer_variant&.true_pay,

      created_at: Time.now,
      updated_at: Time.now,

      gaid: tracking_data[:gaid],
      http_referer: tracking_data[:http_referer],
      http_user_agent: tracking_data[:http_user_agent],
      recorded_at: tracking_data[:recorded_at] || Time.now.to_s(:db),
      subid_1: tracking_data[:subid_1],
      subid_2: tracking_data[:subid_2],
      subid_3: tracking_data[:subid_3],
      subid_4: tracking_data[:subid_4],
      subid_5: tracking_data[:subid_5],
      vtm_campaign: tracking_data[:vtm_campaign],
      vtm_channel: tracking_data[:vtm_channel],
      vtm_host: tracking_data[:vtm_host],
      vtm_page: tracking_data[:vtm_page],

      image_creative_id: tracking_token.image_creative_id,
      mkt_site_id: tracking_token.mkt_site_id,
      text_creative_id: tracking_token.text_creative_id,
      original_currency: Currency.platform_code,
    )

    stat = AffiliateStat.find_by_id(tracking_id)
    stat.mirror_to_redshift
    stat
  end

  def self.bulk_save_clicks(value_array)
    return if value_array.blank?

    ids = value_array.map { |item| item['id'] }

    DotOne::Utils::Rescuer.no_deadlock do
      # Add new or update clicks to database
      AffiliateStat.bulk_insert(*value_array.first.keys, update_duplicates: true) do |worker|
        affiliate_map = {}

        value_array.each do |value_item|
          # Sanitize some data

          # Convert string timestamp to date time
          value_item['recorded_at'] = if value_item['recorded_at'].is_a?(DateTime)
            value_item['recorded_at']
          else
            DateTime.parse(value_item['recorded_at'])
          end

          # Honor max character set by the database
          [*1.upto(5).map { |i| "subid_#{i}" }, 'http_referer', 'http_user_agent', 'vtm_channel'].each do |field|
            value_item[field] = DotOne::Utils.to_utf8(value_item[field].to_s.byteslice(0, 255)).presence
          end

          if value_item['subid_1'] == 'adlinks'
            affiliate_map[value_item['affiliate_id']] ||= []
            affiliate_map[value_item['affiliate_id']] << value_item['recorded_at']
          end

          if value_item['device_model'].is_a?(Array)
            value_item['device_model'] = value_item['device_model'].to_yaml
          end

          worker.add(value_item)
        end

        worker.after_save do |records|
          affiliate_stat_ids = []

          records.each do |x|
            affiliate_stat_ids << x[0]
          end

          missing_ids = ids - AffiliateStat.where(id: ids).pluck(:id)
          if missing_ids.present?
            missing_items = value_array.select { |item| missing_ids.include?(item['id']) }

            File.open(Rails.root.join('tmp/missing_clicks'), 'a') do |file|
              file.puts("#{Time.now}: #{missing_items.to_json}")
            end
            Sentry.capture_message("#bulk_save_clicks missing stats not created: #{missing_ids}", level: :warning)
          end

          AffiliateStats::PersistToReportJob.perform_later(affiliate_stat_ids)

          affiliates = Affiliate.where(id: affiliate_map.keys, ad_link_activated_at: nil)

          affiliates.find_each do |affiliate|
            affiliate.update_attribute(:ad_link_activated_at, affiliate_map[affiliate.id].min)
          end
        end
      end
    end
  end

  def self.record_clicks(offer_variant, tracking_token, tracking_data, options = {})
    current_timestamp = Time.now.to_s(:db)

    return if tracking_token.affiliate_id.blank? && tracking_token.campaign_id.blank?

    affiliate = Affiliate.cached_find(tracking_token.affiliate_id)
    offer = offer_variant&.cached_offer

    unless affiliate_offer_id = tracking_token.affiliate_offer_id.presence
      affiliate_offer = AffiliateOffer.best_match(affiliate, offer) if affiliate
      affiliate_offer_id = affiliate_offer&.id
    end

    geo_ip = geo(tracking_data[:ip_address])
    tracking_id = DotOne::Utils.generate_token

    permitted_tracking_data =  tracking_data.slice(*AffiliateStat.column_names)
    permitted_tracking_data[:aff_uniq_id] ||= tracking_data[:rid] || tracking_data[:RID]

    values_to_save = {
      **permitted_tracking_data,
      id: tracking_id,
      clicks: options[:clicks] || 1,
      status: options[:test] == true ? Order.status_test_conversion : nil,
      network_id: offer&.network_id,
      offer_id: offer&.id,
      offer_variant_id: offer_variant&.id,
      affiliate_id: affiliate&.id,
      affiliate_offer_id: affiliate_offer_id,
      true_pay: options[:payout],
      affiliate_pay: options[:commission],
      mkt_site_id: tracking_data[:mkt_site_id] || tracking_token.mkt_site_id,
      channel_id: tracking_data[:channel_id] || tracking_token.channel_id,
      campaign_id: tracking_data[:campaign_id] || tracking_token.campaign_id,
      ip_country: geo_ip&.country&.name,
      subid_5: permitted_tracking_data[:subid_5] || (tracking_token.v2 ? 'v2' : nil),
      recorded_at: tracking_data[:recorded_at].presence || current_timestamp,
      created_at: current_timestamp,
      updated_at: current_timestamp,
      original_currency: Currency.platform_code,
    }

    unless options[:skip_creatives] == true
      ##
      # When the current image creative is not publishable,
      # then grab the alternative to correct the click stat
      if tracking_token.image_creative_id.present?
        image_creative = ImageCreative.cached_find(tracking_token.image_creative_id)
        alt_image_creative = image_creative&.alternative unless image_creative&.publishable?
        image_creative = alt_image_creative if alt_image_creative
      end

      values_to_save.merge!(
        image_creative_id: image_creative&.id,
        text_creative_id: tracking_token.text_creative_id,
      )
    end

    new_stat = AffiliateStat.new(truncate_values(values_to_save))
    attributes = new_stat.attributes.with_indifferent_access

    if AffiliateStat.is_bot?(new_stat.http_user_agent, new_stat.ip_address, new_stat.http_referer)
      # BotStat.create!(attributes.merge(is_bot: true)) unless AffiliateStat.is_facebook_bot?(new_stat.http_user_agent)
      BotStat.create!(attributes.merge(is_bot: true))
    else
      if options[:delayed] == true
        new_stat.to_kinesis(DotOne::Kinesis::TASK_SAVE_CLICK)
      else
        AffiliateStat.save_click!(attributes)
      end
    end

    ClickStat.new(attributes.merge(v2: tracking_token.v2))
  end

  def self.truncate_values(attributes)
    attributes.map do |key, val|
      column_hash = AffiliateStat.columns_hash[key.to_s]
      column_type = column_hash.type
      column_limit = column_hash.limit

      if val.present? && val.is_a?(String) && column_type == :string
        val = DotOne::Utils.to_utf8(val.byteslice(0, column_limit))
        [key, val]
      else
        [key, val]
      end
    end.to_h
  end
end
