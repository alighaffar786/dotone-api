require 'zip'

class DotOne::AffiliatePayments::Exporter < DotOne::Exporters::Base
  attr_accessor :start_date, :end_date, :paid_date, :download

  def initialize(options)
    @start_date = options[:start_date]
    @end_date = options[:end_date]
    @paid_date = options[:paid_date]
    @download = Download.find(options[:download_id])
  end

  def should_export?
    return start_date.present? && end_date.present? && paid_date.present? && download.present?
  end

  def export
    return unless should_export?

    zip_files = generate_billing_region_zip
    output = generate_zip(zip_files) if zip_files.present?

    if output.present?
      File.open(output, 'rb') { |file| @download.file = file }
      download.status = Download.status_ready
    else
      download.status = Download.status_error
    end

    if download.save!
      File.delete(output) rescue nil

      zip_files.each do |file|
        File.delete(file.last) rescue nil
      end
    end

    download
  end

  def generate_zip(zip_files = [])
    return if zip_files.blank?

    output = generate_temp_filename('zip')

    Zip::File.open(output, Zip::File::CREATE) do |zip|
      zip_files.each do |file|
        zip.add(file.first, File.open(file.last))
      end
    end

    output
  end

  def generate_billing_region_zip
    zip_files = []

    # [nil, AffiliatePayment::BILLING_REGIONS.keys].flatten.each do |region|
    ['all'].flatten.each do |region|
      label = AffiliatePayment::BILLING_REGIONS[region] || 'All'
      output_path = generate_temp_filename('zip')

      files = generate_files(region)

      next if files.blank?

      Zip::File.open(output_path, Zip::File::CREATE) do |zip|
        files.each do |file|
          zip.add("#{file.first}.csv", file.last)
        end
      end

      zip_files << ["#{label.gsub('/', '-')}.zip", output_path]
    end

    zip_files
  end

  def header
    [
      :paid_date,
      :start_date,
      :end_date,
      :affiliate_id,
      :affiliate_name,
      :business_entity,
      :previous_amount,
      :referral_amount,
      :affiliate_amount,
      :total_commissions,
      :tax_filing_country,
      :payment_currency,
      :status,
      :payment_info_status,
      :payment_type,
      :billing_region,
    ]
  end

  def generate_files(billing_region)
    files = []

    AffiliatePayment::AVAILABLE_CURRENCIES.each do |available_currency|
      currency_code = available_currency.to_s

      next unless @body = generate_body(currency_code, billing_region).presence

      files << [currency_code, export_csv]
    end

    files
  end

  def generate_body(currency_code, billing_region)
    affiliates = query_affiliates(currency_code, billing_region)

    return if affiliates.none?

    rows = []

    affiliates.find_in_batches(batch_size: 100) do |group|
      affiliate_ids = group.map(&:id)
      referrer_referral_ids_map = query_referrer_referral_ids_map(affiliate_ids)
      referral_ids = referrer_referral_ids_map.values.flatten
      all_affiliate_ids = affiliate_ids | referral_ids
      stats = query_stats(all_affiliate_ids, currency_code, billing_region)

      group.each do |affiliate|
        # Find its previous_balance, earnings, referral_bonus, total_commissions, overlapped
        previous_balance = affiliate.current_balance.to_f
        approved_affiliate_pay = stats[affiliate.id].to_f
        referral_earnings = referrer_referral_ids_map[affiliate.id].to_a.map { |referral_id| stats[referral_id].to_f }.sum
        referral_bonus = AffiliatePayment.calculate_earnings(referral_earnings)

        # Sum up everything into total commissions
        total_commissions = previous_balance + approved_affiliate_pay + referral_bonus

        next unless total_commissions > 0

        rows << [
          paid_date,
          start_date,
          end_date,
          affiliate.id,
          affiliate.full_name,
          affiliate.business_entity,
          previous_balance.round(2),
          referral_bonus.round(2),
          approved_affiliate_pay.round(2),
          total_commissions.round(2),
          affiliate.tax_filing_country,
          currency_code,
          decide_status(total_commissions, currency_code),
          affiliate.payment_info.status,
          affiliate.payment_info.payment_type,
          billing_region,
        ]
      end
    end

    rows
  end

  def decide_status(amount, currency_code)
    min_redeem_amount = AffiliatePayment::MINIMUM_REDEEM_AMOUNT[currency_code.downcase.to_sym]
    amount >= min_redeem_amount ? AffiliatePayment.status_redeemable : AffiliatePayment.status_deferred
  end

  def overlapped_payment_affiliate_ids(billing_region)
    AffiliatePayment
      .overlapped_payments([], billing_region, start_date, end_date)
      .distinct
      .pluck(:affiliate_id)
  end

  def query_affiliates(currency_code, billing_region)
    preferred_currencies = currency_code == Currency.platform_code ? [currency_code, nil, ''] : currency_code
    Affiliate
      .joins(:payment_info)
      .where(affiliate_payment_infos: { preferred_currency: preferred_currencies })
      .where.not(id: overlapped_payment_affiliate_ids(billing_region))
      .preload(:payment_info)
  end

  def query_stats(affiliate_ids, currency_code, billing_region)
    forex_sql = AffiliateStat.translate_forex_sql('affiliate_pay', currency_code: currency_code)

    AffiliateStat
      .approved_conversions_for_affiliates(affiliate_ids, start_date, end_date)
      .with_billing_regions(billing_region)
      .select("affiliate_id, SUM(ROUND(COALESCE(#{forex_sql}, 0), 2)) AS approved_affiliate_pay")
      .group(:affiliate_id)
      .to_h { |earning| [earning.affiliate_id, earning.approved_affiliate_pay.to_f] }
  end

  def query_referrer_referral_ids_map(referrer_ids)
    Affiliate
      .where(referrer_id: referrer_ids)
      .active_referrals(end_date, TimeZone.platform)
      .select(:id, :referrer_id)
      .group_by(&:referrer_id)
      .transform_values { |v| v.map(&:id) }
  end
end
