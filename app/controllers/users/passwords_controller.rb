class Users::PasswordsController < Devise::PasswordsController
  # Its own memory store: the test cache never counts, and the default file cache would keep a file per address forever.
  RESET_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new

  rate_limit to: 5, within: 1.hour, only: :create, store: RESET_LIMIT_STORE,
             by: -> { params.dig(:user, :email).to_s.strip.downcase },
             with: -> { redirect_to new_user_password_path, alert: 'Too many reset requests for that address. Try again in an hour.' }

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
