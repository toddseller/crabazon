class UserMailer < ActionMailer::Base
  default from: "crabazononline@gmail.com"
  layout 'mailer'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Crabazon')
  end

  def order_email(order, user)
    @order = order
    @user = user
    mail(to: @user.email, subject: "Your Crabazon Order Number #{@order.id}")
  end
end
