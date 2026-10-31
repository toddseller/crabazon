class UserMailer < ActionMailer::Base
  default from: "Crabazon <crabazon@toddseller.com>"
  layout 'mailer'

  def sign_up_attempt(user)
    @user = user
    mail(to: @user.email, subject: 'Someone tried to sign up with your Crabazon address') do |format|
      format.html { render layout: 'email' }
    end
  end

  def order_email(order, user)
    @order = order
    @user = user
    mail(to: @user.email, subject: "Your Crabazon Order Number #{@order.id}")
  end
end
