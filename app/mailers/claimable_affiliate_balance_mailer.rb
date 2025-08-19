class ClaimableAffiliateBalanceMailer < BaseMailer
  def send_report(user, report_paths, email_template)
    @email_content = Liquid::Template.parse(email_template.t_content)
    @email_sender = Liquid::Template.parse(email_template.sender)
    @email_subject = Liquid::Template.parse(email_template.t_subject)
    today = DateTime.now.strftime('%Y-%m-%d')

    @subject = @email_subject.render('local_time' => today)
    email_template = @email_content.render('local_time' => today)

    @sender = @email_sender.render(
      'company_name' => DotOne::Setup.wl_name,
      'company_affiliate_contact_email' => DotOne::Setup.general_contact_email,
    )

    report_paths.each do |path|
      pathname = Pathname.new(path)
      attachments[pathname.basename.to_s] = {
        mime_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        content: File.read(pathname).tap { File.delete(pathname) },
      }
    end
    construct_email(email_template, {
      to: user.email,
      from: @sender,
      subject: @subject,
    })
  end
end
