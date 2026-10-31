class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # Written out because Devise's create renders after its block, and a taken
  # address has to get the same redirect as a new sign-up, not the form.
  def create
    build_resource(sign_up_params)
    resource.save
    if resource.errors.of_kind?(:email, :taken)
      resource.errors.delete(:email, :taken)
      if resource.errors.empty?
        owner = User.find_by!(email: resource.email)
        # An owner who never confirmed can't sign in yet, so they need the link, not the notice.
        owner.confirmed? ? UserMailer.sign_up_attempt(owner).deliver_later : owner.send_confirmation_instructions
        return redirect_to after_inactive_sign_up_path_for(resource)
      end
    end

    if resource.persisted?
      # Confirmable leaves every new account inactive until its address is confirmed.
      expire_data_after_sign_in!
      redirect_to after_inactive_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def sent
    @email = flash[:sign_up_email]
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_inactive_sign_up_path_for(resource)
    # The sent page says this itself, so Devise's notice would repeat it.
    flash.delete(:notice)
    flash[:sign_up_email] = resource.email
    user_sign_up_sent_path
  end
end
