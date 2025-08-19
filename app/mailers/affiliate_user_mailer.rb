class AffiliateUserMailer < BaseMailer
  def notify_negative_balance_advertisers(outputs)
    attachments['Overview.csv'] = { content: File.read(outputs[:output_csv]) }
    attachments['Overview.xlsx'] = { content: File.read(outputs[:output_xlsx]) }

    File.delete(outputs[:output_csv]) rescue nil
    File.delete(outputs[:output_xlsx]) rescue nil

    mail(
      to: ops_team_email,
      from: company_email(:general),
      subject: st('emails.affiliate_users.negative_balance_advertisers.subject', {
        company_name: DotOne::Setup.wl_name,
        locale: Language.current_locale,
      }),
      body: st('emails.affiliate_users.negative_balance_advertisers.text', {
        company_name: DotOne::Setup.wl_name,
        # TODO: update url to v2
        url: 'https://team.affiliates.one/teams/advertiser_balances/remaining',
        locale: Language.current_locale,
      }),
    )
  end

  def new_missing_orders(affiliate_user, date, count)
    @email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_NEW_MISSING_ORDERS)

    construct_email(@email_template, {
      missing_orders_count: count,
      date: date,
      recipient_email: affiliate_user.email,
      recipient_full_name: affiliate_user.full_name,
    })
  end

  def notify_product_api_update(offer_id, network)
    @network = network
    @affiliate_users = @network.affiliate_users
    @admin_link = "#{DotOne::Setup.admin_url}/offers/#{offer_id}?tab=clientApi"
    emails = @affiliate_users.pluck(:email)
    to_email = emails.first
    cc_emails = emails[1..]

    mail(
      to: to_email,
      cc: cc_emails.presence,
      from: DotOne::Setup.general_contact_email,
      subject: 'Product API setup request',
    )
  end
end
