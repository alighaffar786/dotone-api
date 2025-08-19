class NewsletterMailer < BaseMailer
  def email_message(newsletter, recipient)
    email_template = newsletter.email_template

    return if email_template.blank? || recipient.blank? || !valid_email?(recipient.email.to_s)

    affiliate = recipient.is_a?(Affiliate) ? recipient : nil
    advertiser = recipient.is_a?(Network) ? recipient : nil

    construct_email(email_template, {
      affiliate: affiliate,
      advertiser: advertiser,
      company: DotOne::Setup.wl_company,
      recipient_email: recipient.email,
      from: to_full_email(newsletter.sender),
      to: to_full_email(recipient),
      cc: true,
    })

    recipient.trace!(Trace::VERB_EMAILS, {
      changes: {
        email_type: "#{self.class.name}.#{__method__}",
        email_address: to_full_email(recipient),
        newsletter_id: newsletter.id,
      },
    })
  end
end
