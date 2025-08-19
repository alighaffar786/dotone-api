class AffiliateMailer < BaseMailer
  helper(EmailHelper)

  def campaign_invite(affiliate, affiliate_offer_ids, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_INVITE_ADLINK)

    affiliate_offers = AffiliateOffer.where(id: affiliate_offer_ids).to_a

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      current_user: affiliate,
      affiliate: affiliate,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      affiliate_offers_url_block: affiliate_offers_url_block(affiliate, affiliate_offers),
    }))

    affiliate_offers.each do |affiliate_offer|
      affiliate_offer.affiliate.trace!(
        Trace::VERB_EMAILS,
        changes: {
          email_type: "#{self.class.name}.#{__method__}",
          email_address: to_full_email(affiliate),
          offer: affiliate_offer.offer.id_with_name,
        },
      )
    end
  end

  def campaign_paused(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_PAUSED)

    affiliate = affiliate_offer.affiliate

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      current_user: affiliate,
      affiliate: affiliate,
      offer: affiliate_offer.offer,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      affiliate_offer_url: DotOne::ClientRoutes.affiliates_offer_url(affiliate_offer.offer.id, locale: affiliate.locale),
    }))

    affiliate_offer.affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: affiliate_offer.offer.id_with_name,
      },
    )
  end

  def campaign_approved(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_APPROVED)

    affiliate = affiliate_offer.affiliate

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      offer: affiliate_offer.offer,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      affiliate_offer_url: DotOne::ClientRoutes.affiliates_offer_url(affiliate_offer.offer.id, locale: affiliate.locale),
    }))

    affiliate_offer.affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: affiliate_offer.offer.id_with_name,
      },
    )
  end

  def campaign_rejected(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_REJECTED)

    affiliate = affiliate_offer.affiliate

    construct_email(@email_template, options.merge({
      affiliate: affiliate,
      current_user: affiliate,
      offer: affiliate_offer.offer,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      affiliate_offer_url: DotOne::ClientRoutes.affiliates_offer_url(affiliate_offer.offer.id, locale: affiliate.locale),
    }))

    affiliate_offer.affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: affiliate_offer.offer.id_with_name,
      },
    )
  end

  def event_campaign_selected(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_EVENT_CAMPAIGN_SELECTED)

    affiliate = affiliate_offer.affiliate
    offer = affiliate_offer.offer

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      offer: offer,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      affiliate_offer_url: DotOne::ClientRoutes.affiliates_event_offer_url(offer.id, locale: affiliate.locale),
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def event_campaign_changes_required(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_EVENT_CAMPAIGN_CHANGES_REQUIRED)

    affiliate = affiliate_offer.affiliate
    offer = affiliate_offer.offer
    event_info = offer.event_info

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      offer: offer,
      event_info: event_info,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def event_campaign_completed(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_EVENT_CAMPAIGN_COMPLETED)

    affiliate = affiliate_offer.affiliate
    offer = affiliate_offer.offer
    event_info = offer.event_info

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      offer: offer,
      event_info: event_info,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def event_campaign_rejected(affiliate_offer, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_EVENT_CAMPAIGN_REJECTED)

    affiliate = affiliate_offer.affiliate
    offer = affiliate_offer.offer
    event_info = offer.event_info

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      offer: offer,
      event_info: event_info,
      affiliate_offer: affiliate_offer,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def xhour_offer_paused(offer, affiliate, hour, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_OFFER_PAUSED_XHOUR)
    construct_email(@email_template, options.merge({
      offer: offer,
      affiliate: affiliate,
      current_user: affiliate,
      recipient_full_name: affiliate.full_name,
      recipient_email: affiliate.email,
      hour_left: hour.to_s,
    }))

    return unless affiliate.present?

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name, hour: hour
      },
    )
  end

  def immediate_offer_paused(offer, affiliate, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_OFFER_PAUSED_IMMEDIATE)
    construct_email(@email_template, options.merge({
      offer: offer,
      affiliate: affiliate,
      current_user: affiliate,
      recipient_full_name: affiliate.full_name,
      recipient_email: affiliate.email,
    }))

    return unless affiliate.present?

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def immediate_offer_status_changed(offer, affiliate, status, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_OFFER_STATUS_CHANGE)
    construct_email(@email_template, options.merge({
      offer: offer,
      affiliate: affiliate,
      current_user: affiliate,
      recipient_full_name: affiliate.full_name,
      status: status,
      recipient_email: affiliate.email,
    }))

    return unless affiliate.present?

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        offer: offer.id_with_name,
      },
    )
  end

  def missing_order_approved(affiliate, missing_order, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ORDER_INQUIRY_APPROVED)

    options = {
      company_name: DotOne::Setup.wl_name,
      company_affiliate_contact_email: DotOne::Setup.affiliate_contact_email,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      missing_order_id: missing_order.id,
    }

    template = @email_template.render_template(options)

    construct_email(template[:content], options.merge({
      affiliate: affiliate,
      from: template[:sender],
      to: template[:recipient],
      subject: template[:subject],
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        missing_order: missing_order.id,
      },
    )
  end

  def missing_order_confirming(affiliate, missing_order, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ORDER_INQUIRY_CONFIRMING)

    options = {
      company_name: DotOne::Setup.wl_name,
      company_affiliate_contact_email: DotOne::Setup.affiliate_contact_email,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      missing_order_id: missing_order.id,
      missing_order_click_time: missing_order.click_time,
      missing_order_offer_id_with_name: missing_order.order_id? ? "#{missing_order.offer.id} - #{missing_order.offer.name}" : '',
      missing_order_currency_code: missing_order&.currency&.code,
      missing_order_order_number: missing_order.order_number,
      missing_order_order_time: missing_order.order_time,
      missing_order_order_total: missing_order.order_total,
      missing_order_payment_method: missing_order.payment_method,
      missing_order_device: missing_order.device,
    }
    template = @email_template.render_template(options)

    construct_email(template[:content], options.merge({
      affiliate: affiliate,
      from: template[:sender],
      to: template[:recipient],
      subject: template[:subject],
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        missing_order: missing_order.id,
      },
    )
  end

  def missing_order_rejected(affiliate, missing_order, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_ORDER_INQUIRY_REJECTED)

    options = {
      company_name: DotOne::Setup.wl_name,
      company_affiliate_contact_email: DotOne::Setup.affiliate_contact_email,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      missing_order_id: missing_order.id,
      missing_order_status_summary: missing_order.status_summary,
      missing_order_status_reason: missing_order.status_reason,
    }

    template = @email_template.render_template(options)

    construct_email(template[:content], options.merge({
      affiliate: affiliate,
      from: template[:sender],
      to: template[:recipient],
      subject: template[:subject],
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
        missing_order: missing_order.id,
      },
    )
  end

  # TODO: Liquidify
  def verification_instructions(affiliate, options = {})
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_EMAIL_VERIFICATION)

    verify_url_options = {
      token: affiliate.unique_token,
      locale: affiliate.locale,
    }

    verify_url_options[:transaction_id] = options[:transaction_id] if options[:transaction_id].present?

    construct_email(@email_template, {
      affiliate: affiliate,
      current_user: affiliate,
      email_verification_url: DotOne::ClientRoutes.affiliates_email_verification_url(verify_url_options),
      recipient_email: affiliate.email,
    })

    affiliate.trace!(Trace::VERB_EMAILS, { changes: {
      email_type: "#{self.class.name}.#{__method__}",
      email_address: to_full_email(affiliate)
    } })
  end

  # TODO: Liquidify
  def password_reset(affiliate)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_PASSWORD_RESET)
    construct_email(@email_template, {
      affiliate: affiliate,
      current_user: affiliate,
      password_reset_url: DotOne::ClientRoutes.affiliates_password_reset_url(token: affiliate.unique_token, locale: affiliate.locale),
      recipient_email: affiliate.email,
    })

    affiliate.trace!(Trace::VERB_EMAILS, { changes: {
      email_type: "#{self.class.name}.#{__method__}",
      email_address: to_full_email(affiliate)
    } })
  end

  def payment_info_confirmed(affiliate)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_CONFIRMED)
    construct_email(@email_template, {
      affiliate: affiliate,
      current_user: affiliate,
      recipient_email: affiliate.email,
    })

    affiliate.trace!(
      Trace::VERB_EMAILS,
      {
        changes: {
          email_type: "#{self.class.name}.#{__method__}",
          email_address: to_full_email(affiliate),
        },
      },
    )
  end

  def payment_info_incomplete(affiliate)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_INCOMPLETE)
    construct_email(@email_template, {
      affiliate: affiliate,
      current_user: affiliate,
      recipient_email: affiliate.email,
      payment_info_form_url: DotOne::ClientRoutes.affiliates_profile_url(locale: affiliate.locale),
    })

    affiliate.trace!(
      Trace::VERB_EMAILS,
      {
        changes: {
          email_type: "#{self.class.name}.#{__method__}",
          email_address: to_full_email(affiliate),
        },
      },
    )
  end

  def notify_campaign_cap_depleting(affiliate_offer, recipient, cap_percentage_used)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_CAP_DEPLETING)

    affiliate = affiliate_offer.affiliate

    return unless @email_template

    construct_email(@email_template, {
      affiliate_offer: affiliate_offer,
      recipient_email: recipient.email,
      recipient_full_name: recipient.full_name,
      affiliate: affiliate,
      current_user: affiliate,
      offer: affiliate_offer.offer,
      current_time: TimeZone.current.from_utc(Time.now).to_s(:db),
      cap_percentage_used: cap_percentage_used,
    })
    recipient.trace!(Trace::VERB_EMAILS, {
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
        offer: affiliate_offer.offer.id_with_name,
      },
    })
  end

  def notify_campaign_cap_depleted(affiliate_offer, recipient, cap_percentage_used)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CAMPAIGN_CAP_DEPLETED)

    affiliate = affiliate_offer.affiliate

    return unless @email_template

    construct_email(@email_template, {
      affiliate_offer: affiliate_offer,
      recipient_email: recipient.email,
      recipient_full_name: recipient.full_name,
      affiliate: affiliate,
      current_user: affiliate,
      offer: affiliate_offer.offer,
    })

    recipient.trace!(Trace::VERB_EMAILS, {
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
        offer: affiliate_offer.offer.id_with_name,
      },
    })
  end

  def notify_offer_cap_depleting(offer, recipient, cap_percentage_used)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_OFFER_CAP_DEPLETING)

    affiliate = recipient.is_a?(Affiliate) ? recipient : nil

    construct_email(@email_template, {
      recipient_email: recipient.email,
      recipient_full_name: recipient.full_name,
      offer: offer,
      current_user: affiliate,
      current_time: TimeZone.current.from_utc(Time.now).to_s(:db),
      cap_percentage_used: cap_percentage_used,
    })

    recipient.trace!(Trace::VERB_EMAILS, {
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
        offer: offer.id_with_name
      }
    })
  end

  def notify_offer_cap_depleted(offer, recipient, cap_percentage_used)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_OFFER_CAP_DEPLETED)

    affiliate = recipient.is_a?(Affiliate) ? recipient : nil

    construct_email(@email_template, {
      recipient_email: recipient.email,
      recipient_full_name: recipient.full_name,
      offer: offer,
      current_user: affiliate,
    })

    recipient.trace!(Trace::VERB_EMAILS, {
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
        offer: offer.id_with_name
      }
    })
  end

  def aff_offer_approval_permission_request(affiliate_offer)
    @wl_company = DotOne::Setup.wl_company
    @affiliate_offer = affiliate_offer
    @offer = affiliate_offer.offer
    @affiliate = affiliate_offer.affiliate

    @affiliate_user, *rest_affiliate_users = @affiliate.affiliate_users

    cc = rest_affiliate_users.map(&:email)
    subject = st('emails.affiliates.aff_offer_approval_permission_request_subject', locale: Language.current_locale)

    mail(from: company_email(:general), to: @affiliate_user.email, subject: subject, cc: cc) do |format|
      format.html { render 'affiliate_offer_request', formats: [:html] }
    end
  end

  def status_active(affiliate, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_STATUS_ACTIVE)

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
      login_url: affiliates_login_url(
        host: DotOne::Setup.affiliate_host,
      ),
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
      },
    )
  end

  def status_suspended(affiliate, **options)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_AFFILIATE_STATUS_SUSPENDED)

    construct_email(@email_template, options.merge({
      company: DotOne::Setup.wl_company,
      affiliate: affiliate,
      current_user: affiliate,
      recipient_email: affiliate.email,
      recipient_full_name: affiliate.full_name,
    }))

    affiliate.trace!(
      Trace::VERB_EMAILS,
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(affiliate),
      },
    )
  end
end
