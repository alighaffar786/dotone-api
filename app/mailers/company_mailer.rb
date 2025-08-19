class CompanyMailer < ActionMailer::Base
  def contact_form(options = {})
    @info = options
    domain = @info[:domain] || 'VibrantAds.com'
    subject = @info[:subject] || "Inquiry from #{domain}"
    mail(
      from: options[:email],
      to: 'efaizal@vibrantads.com',
      subject: subject,
      date: Time.now,
    )
  end

  def partner_contact_form(options = {})
    @info = options
    mail(
      from: options[:email],
      to: 'efaizal@vibrantads.com',
      subject: 'Inquiry from VibrantAds.com',
      date: Time.now,
    )
  end
end
