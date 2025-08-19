require 'open-uri'
require 'date'

class OwnerMailer < BaseMailer
  def password_reset(user)
    @user = user
    @wl_company = DotOne::Setup.wl_company
    subject = st('emails.owners.password_reset_instructions_subject', locale: Language.current_locale,
      company_name: @wl_company.name)
    mail(
      from: company_email(@wl_company),
      to: @user.email,
      subject: subject,
      date: Time.now,
    ) do |format|
      format.text do
        render text: st('emails.owners.password_reset_instructions.text', {
          locale: Language.current_locale,
          username: @user.name,
          company_name: @wl_company.name,
          company_email: @wl_company.general_contact_email,
          password_reset_url: change_owners_password_resets_url(t: @user.perishable_token, type: 'owner',
            host: @wl_company.owner_domain_name),
        })
      end
    end
  end

  def invoice_email(invoice, recipient)
    return if invoice.blank? || recipient.blank?

    @invoice = invoice
    @wl_company = invoice.wl_company
    subject = "[Converly] Your #{Date::MONTHNAMES[@invoice.month]} #{@invoice.year} Invoice"
    attachments['invoice.pdf'] = open(@invoice.file.url).read
    mail(from: 'billing@converly.com', to: recipient, subject: subject)
  end
end
