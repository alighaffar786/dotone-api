class SkinMailer < ActionMailer::Base
  def contact_us(options = {})
    @info = options
    domain = @info[:domain]
    subject = "Contact Us from #{domain}"

    mail(
      from: options[:from],
      to: options[:to],
      subject: subject,
      date: Time.now,
    )
  end

  def newsletter_signup(options = {})
    @info = options
    domain = @info[:domain]
    bcc = ['efaizal@vibrantads.com']
    bcc << options[:bcc]
    subject = "Newsletter Signup from #{domain}"
    mail(
      from: 'admin@vibrantads.com',
      to: options[:to],
      bcc: bcc.compact,
      subject: subject,
      date: Time.now,
    )
  end
end
