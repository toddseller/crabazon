class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super

  #   p '*********************'
  #   p params
  #   @user = User.new(params[:email])
  #   p '*********************'
  #   p @user
  #   respond_to do |format|
  #     if @user.save
  #       p '****************'
  #       p 'Bitches'
  #       UserMailer.welcome_email(@user).deliver_now
  #       format.html { redirect_to(@user, notice: 'User was successfully created.') }
  #       format.json { render json: @user, status: :created, location: @user }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def create
  #   p '*********************'
  #   p params
  #   @user = User.new(configure_sign_in_params)
  #   p '*********************'
  #   p @user
  #   respond_to do |format|
  #     if @user.save
  #       p '****************'
  #       p 'Bitches'
  #       UserMailer.welcome_email(@user).deliver_now
  #       format.html { redirect_to(@user, notice: 'User was successfully created.') }
  #       format.json { render json: @user, status: :created, location: @user }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :attribute
  end
end
