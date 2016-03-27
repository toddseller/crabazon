class UserMailer < ActionMailer::Base
  default from: "oldfatbastard666@gmail.com"
  layout 'mailer'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Crabazon')
  end
end
