class Users::PasswordsController < Devise::PasswordsController
  def sent
    @email = flash[:reset_email]
  end

  protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    # The sent page says this itself, so Devise's notice would repeat it.
    flash.delete(:notice)
    flash[:reset_email] = resource.email
    user_password_sent_path
  end
end
