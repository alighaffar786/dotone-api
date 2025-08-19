class UserMailer < BaseMailer
  default from: DEFAULT_EMAIL_FROM

  def activation_confirmation(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: 'Welcome to VibrantAds.com',
      date: Time.now,
    )
  end

  def activation_instructions(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: 'Please Activate Your Account',
      date: Time.now,
    )
  end

  def password_reset_instructions(user)
    @url = "#{DotOne::Setup.admin_url}/password/new?token=#{user.unique_token}" if user.is_a?(AffiliateUser)

    mail(
      to: email_with_name(user),
      subject: 'Password Reset Instructions From Convertrack.com',
      date: Time.now,
    )
  end

  def deletion(user, payload)
    mail(
      to: 'efaizal@vibrantads.com',
      subject: "Data Deletion request - [#{user.model_name.name} - #{user.id}]",
      data: Time.now,
      body: "User request data deletion from [#{payload[:provider]} - ID: #{payload[:user_id]}]",
    )
  end

  def deauthorize(user, payload)
    mail(
      to: 'efaizal@vibrantads.com',
      subject: "Deauthorize user request - [#{user.model_name.name} - #{user.id}]",
      data: Time.now,
      body: "User request deauthorize from [#{payload[:provider]} - ID: #{payload[:user_id]}]",
    )
  end

  def tfa(user)
    mail(
      to: to_full_email(user),
      subject: '2FA',
      body: t('verification.code', tfa: user.tfa_code)
    )
  end

  private

  def email_with_name(user)
    "#{user.full_name} <#{user.email}>"
  end
end
