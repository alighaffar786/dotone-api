class CmsContentMailer < ActionMailer::Base
  def content_share(from_email, from_name, to_email, content)
    @cms_content = content
    @from_name = from_name

    mail(
      from: "#{from_name} <#{from_email}>",
      to: to_email,
      subject: "#{from_name} wants to share NextCrave post with you",
      date: Time.now,
    )
  end
end
