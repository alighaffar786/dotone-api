class CmsUserMailer < ActionMailer::Base
  def verification_instructions(cms_user)
    @cms_user = cms_user
    @domain = cms_user.cms_domain
    mail(
      from: "#{@domain.name} team <#{@domain.do_not_reply_email}>",
      to: email_with_username(cms_user),
      subject: 'Please Verify Your Email',
      date: Time.now,
    )
  end

  private

  def email_with_username(user)
    "#{user.username} <#{user.email}>"
  end
end
