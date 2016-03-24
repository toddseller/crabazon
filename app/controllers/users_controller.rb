class UsersController < ApplicationController
  # before_action :authenticate_user!

  def new
    @user = User.new
  end

  def create
    p '*********************'
    p params
    @user = User.new(params[:email])
    p '*********************'
    p @user
    respond_to do |format|
      if @user.save
        p '****************'
        p 'Bitches'
        UserMailer.welcome_email(@user).deliver_now
        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @user = User.find(1)
    @products = Product.sort_by_price
    render 'index/index'
  end
end
