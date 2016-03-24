class UsersController < ApplicationController
  before_action :authenticate_user!

  def new
    @user = User.new
  end

  def create

  end

  def show
    @products = Product.sort_by_price
    render 'index/index'
  end
end
