class AdvertiserMailer < BaseMailer
  helper(EmailHelper)

  layout 'network_mailer'

  def password_reset_instruction_email(advertiser)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_PASSWORD_RESET)

    construct_email(@email_template, {
      advertiser: advertiser,
      current_user: advertiser,
      password_reset_url: "#{DotOne::Setup.advertiser_url}/password/new?token=#{advertiser.unique_token}",
      recipient_email: advertiser.email,
    })

    advertiser.trace!(Trace::VERB_EMAILS, { changes: {
      email_type: "#{self.class.name}.#{__method__}",
      email_address: advertiser.email,
    } })
  end

  def banner_creative_rejected(advertiser, banners, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_BANNER_CREATIVE_REJECTED)

    banners_to_show = banners[0, 3]
    size_for_more = banners.length - banners_to_show.length
    size_for_more_string = size_for_more.positive? ? st('shared.And n More Banners', n: size_for_more) : ''
    rejected_reason = banners.first.status_reason
    offer = banners_to_show.first.cached_offer_variant.cached_offer

    construct_email(@email_template, options.merge({
      advertiser: advertiser,
      current_user: advertiser,
      recipient_full_name: advertiser.full_name,
      recipient_email: advertiser.email,
      rejected_reason: rejected_reason,
      banner_list: render_to_string({
        partial: 'advertiser_mailer/banner_list', locals: {
          banners: banners,
          size_for_more_string: size_for_more_string,
        }
      }),
      offer: offer,
    }))

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: advertiser.email,
      },
    )
  end

  ##
  # Mailer to send any rejected text creative notification.
  def text_creative_rejected(advertiser, text_creative, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_FEED_CREATIVE_REJECTED)

    construct_email(@email_template, options.merge({
      advertiser: advertiser,
      current_user: advertiser,
      recipient_full_name: advertiser.full_name,
      recipient_email: advertiser.email,
      offer: text_creative.offer_variant.offer,
    }))

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: advertiser.email,
      },
    )
  end

  def missing_order_reminder(advertiser, missing_order, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ORDER_INQUIRY_REMINDER)

    options = {
      company_name: DotOne::Setup.wl_name,
      company_affiliate_contact_email: DotOne::Setup.affiliate_contact_email,
      recipient_email: advertiser.email,
      recipient_full_name: advertiser.full_name,
      remaining_days: missing_order.days_until_auto_approval,
      missing_order_id: missing_order.id,
      order_inquiry_url: DotOne::ClientRoutes.advertiser_missing_orders_url(locale: advertiser.locale)
    }

    template = @email_template.render_template(options)

    construct_email(template[:content], options.merge({
      advertiser: advertiser,
      from: template[:sender],
      to: template[:recipient],
      subject: template[:subject],
    }))

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(advertiser),
      },
    )
  end

  def status_pending(network)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_STATUS_PENDING)
    construct_email(@email_template, {
      company: DotOne::Setup.wl_name,
      advertiser: network,
      current_user: network,
      to: network.contact_email,
      recipient_full_name: "#{network.contact_name} (#{network.name})",
      recipient_email: network.contact_email,
    })

    network.trace!(Trace::VERB_EMAILS, { changes: {
      email_type: "#{self.class.name}.#{__method__}",
      email_address: to_full_email(network),
    }})
  end

  def status_active(network, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_STATUS_ACTIVE)

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      advertiser: network,
      current_user: network,
      recipient_email: network.email,
      recipient_full_name: network.full_name,
      login_url: DotOne::ClientRoutes.advertisers_login_url(locale: network.locale),
    }))

    network.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(network),
      },
    )
  end

  def status_suspended(advertiser, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED)

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      advertiser: advertiser,
      current_user: advertiser,
      recipient_email: advertiser.email,
      recipient_full_name: advertiser.full_name,
    }))

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(advertiser),
      },
    )
  end

  def status_suspended_due_to_gdpr(advertiser, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED_DUE_TO_GDPR)

    recipient, *cc = advertiser.affiliate_users
    construct_email(@email_template, {
      company: DotOne::Setup.wl_company,
      advertiser: advertiser,
      current_user: advertiser,
      recipient_email: recipient.email,
      recipient_full_name: recipient.full_name,
      cc: options[:cc] == true ? cc : options[:cc],
    })

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
      },
    )
  end

  def gdpr_data_ready(advertiser, data_url, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_GDPR_DATA_READY)

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      advertiser: advertiser,
      current_user: advertiser,
      recipient_email: advertiser.email,
      recipient_full_name: advertiser.full_name,
      data_url: data_url,
    }))

    advertiser.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(advertiser),
      },
    )
  end

  def send_monthly_reports_email(network, data = {}, **options)
    locale = options[:locale] || Language.platform_locale,

    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ADVERTISER_MONTHLY_REPORT)
    @email_content = Liquid::Template.parse(@email_template.t_content(locale))
    @email_sender = Liquid::Template.parse(@email_template.sender)
    @email_subject = Liquid::Template.parse(@email_template.t_subject(locale))

    @email_template = @email_content.render(
      'native_ad_count' => data[:native_ad_count].to_i,
      'impression_count' => data[:impression_count].to_i,
      'detail_views_count' => data[:detail_views_count].to_i,
      'click_count' => data[:click_count].to_i,
      'present_month_orders' => data[:present_month_orders].to_i,
      'active_affiliate_count' => data[:active_affiliate_count].to_i,
      'last_month_orders' => data[:last_month_orders].to_i,
      'orders_difference' => data[:orders_difference].to_i,
      'last_month' => 1.month.ago.strftime('%B').to_s,
      'last_two_month' => (DateTime.now - 2.month).strftime('%B').to_s,
      'end_of_last_month' => 1.month.ago.end_of_month.day.to_s,
      'company_name' => DotOne::Setup.wl_name,
    )

    @subject = @email_subject.render('company_name' => DotOne::Setup.wl_name)
    @sender = @email_sender.render(
      'company_name' => DotOne::Setup.wl_name,
      'sender_email' => DotOne::Setup.general_contact_email,
    )

    construct_email(@email_template, options.merge({
      advertiser: network,
      to: network.full_name_with_email,
      from: @sender,
      subject: @subject,
    }))
  end

  def stat_summary(network)
    @network = network
    time_zone = TimeZone.platform
    date_range = time_zone.local_range(:last_month)

    @params = { start_date: date_range[0], end_date: date_range[1], time_zone: time_zone }

    performance = DotOne::Reports::Networks::StatSummary.new(
      network,
      @params.merge(columns: [:clicks, :offer_id], date_type: :recorded_at)
    )

    conversion = DotOne::Reports::Networks::StatSummary.new(
      network,
      @params.merge(
        approval: AffiliateStat.approval_pending,
        columns: [:offer_id, :pending_conversions, :order_total, :total_true_pay],
        date_type: :captured_at,
      )
    )

    confirmed = DotOne::Reports::Networks::StatSummary.new(
      network,
      @params.merge(
        columns: [:offer_id, :published_conversions, :rejected_conversions, :order_total, :total_true_pay],
        date_type: :converted_at,
      )
    )

    @conversion_summary = conversion.generate.index_by(&:offer_id)
    @confirmed_summary = confirmed.generate.index_by(&:offer_id)
    @performance_summary = performance.generate.index_by(&:offer_id)

    offer_ids = [
      @performance_summary.values.reject { |x| x.clicks.to_i < 100 }.map(&:offer_id),
      @conversion_summary.keys,
      @confirmed_summary.keys,
    ].flatten.uniq

    return if offer_ids.blank?

    @confirmed_total = confirmed.total

    @offers = NetworkOffer.where(id: offer_ids)

    @affiliate_offers = AffiliateOffer
      .where(offer: @offers)
      .between(*date_range, :created_at, time_zone)
      .group(:offer_id)
      .count

    I18n.with_locale(network.locale) do
      mail(
        from: DotOne::Setup.general_contact_email,
        to: network.full_name_with_email,
        subject: t('.subject', month: t('date.month_names')[params[:end_date].month], year: params[:end_date].year),
        cc: [cc_recipients(cc: true, advertiser: network)].push(SUPPORT_EMAIL).compact,
      )
    end
  end
end
