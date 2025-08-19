class SuggestionMailer < ActionMailer::Base
  def submit(user, subject, content)
    @from_name = [user.first_name, user.last_name].join(',')
    @from_email = user.email
    @to_email = 'efaizal@vibrantads.com'
    @subject = subject
    @content = content
    mail(
      from: "#{@from_name} <#{@from_email}>",
      to: @to_email,
      subject: 'Advertiseen Suggestion Submission',
      date: Time.now,
    )
  end
end
