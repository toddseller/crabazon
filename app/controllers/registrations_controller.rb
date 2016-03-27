class RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
  end

  def create
    p '*********************'
    p params
    @user = User.new(params[user_params])
    p '*********************'
    p @user
    respond_to do |format|
      if @user.save
        UserMailer.welcome_email(@user).deliver_later
        format.html { redirect_to(index_path, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:email,)
  end
end
