class BaseMailer < ActionMailer::Base
  include EmailHelper

  ##
  # Some additional helpers to use on rendering mail
  helper(EmailHelper)

  SUPPORT_EMAIL = 'support@upstartdna.com'

  def st(key, options = {})
    locale = options[:locale]
    locale = @locale if locale.blank?
    locale = @affiliate && @affiliate.locale if locale.blank?
    locale = Language.platform_locale if locale.blank?
    I18n.t(key, **options.merge(locale: locale))
  end

  ##
  # Helper to execute email rendering.
  def construct_email(email_template, options = {})
    return if email_template.blank?

    locale = options[:current_user]&.locale || I18n.locale

    I18n.with_locale(locale) do
      @email_template = email_template

      if options[:attachment] && [:content, :type, :name].all? { |s| options[:attachment].key? s }
        attachments[options[:attachment][:name]] =
          { mime_type: options[:attachment][:type], content: options[:attachment][:content] }
      end

      if @email_template.is_a?(EmailTemplate)
        options = options.merge(company: DotOne::Setup.wl_company)
        token_materials = options.except(:from, :to, :current_user, :cc)
        email_template.tokenize(token_materials)

        from = options[:from] || email_template.sender_tokenized(:email)
        to = options[:to] || email_template.recipient_tokenized(:email)
        subject = email_template.t_subject_tokenized(:email)
        layout = 'mailer_templates/legacy'
      else
        from = options[:from]
        to = options[:to]
        subject = options[:subject]
        layout = "mailer_templates/#{options[:layout] || 'default'}"
      end

      mail(from: from, to: to, subject: subject, cc: cc_recipients(options)) do |format|
        format.text { render layout, formats: [:text] }
        format.html { render layout, formats: [:html] }
      end
    end
  end

  # based on the type, it produces the email address. By default, it will use the
  # company's general contact email.
  def company_email(type = :general)
    if type == :affiliate && DotOne::Setup.affiliate_contact_email.present?
      "#{DotOne::Setup.wl_name} <#{DotOne::Setup.affiliate_contact_email}>"
    else
      "#{DotOne::Setup.wl_name} <#{DotOne::Setup.general_contact_email}>"
    end
  end

  ##
  # SMTP such as GMail will require
  # sender and recipient to have the following format:
  # Name <email@domain.com>
  # Or if there is no Name, use the following format:
  # email@domain.com <email@domain.com>
  def to_full_email(entity)
    if entity.is_a?(String)
      "#{entity} <#{entity}>"
    elsif entity.respond_to?(:full_name)
      full_name = entity.full_name.to_s.gsub(/[^0-9a-zA-Z\s]+/, '')
      "#{full_name} <#{entity.email}>"
    end
  end

  def ops_team_email
    'Ops Team <op@upstartdna.com>'
  end

  def valid_email?(email)
    ValidateEmail.valid?(email) == true
  end

  def cc_recipients(options)
    return unless options[:cc]

    cc = options[:cc]
    if cc.is_a?(String) || cc.is_a?(Array)
      cc
    elsif (network = options[:advertiser])
      network.mailing_list
    elsif (affiliate = options[:affiliate])
      affiliate.mailing_list
    end
  end
end
