class WeeklyPerformanceMailer < BaseMailer
  def send_report(user, content, email_template)
    @email_content = Liquid::Template.parse(email_template.t_content)
    @email_sender = Liquid::Template.parse(email_template.sender)
    @email_subject = Liquid::Template.parse(email_template.t_subject)
    today = DateTime.now.strftime('%Y-%m-%d')

    @subject = @email_subject.render(
      'company_name' => DotOne::Setup.wl_name,
      'local_time' => today,
    )

    @sender = @email_sender.render(
      'company_name' => DotOne::Setup.wl_name,
      'company_affiliate_contact_email' => DotOne::Setup.wl_company&.general_contact_email,
    )

    email_template = @email_content.render('local_time' => today)

    construct_email(email_template, {
      to: user.email,
      from: @sender,
      subject: @subject,
      attachment: {
        content: content,
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        name: 'weekly_performance_report.xls',
      },
      layout: 'internal',
    })
  end
end
