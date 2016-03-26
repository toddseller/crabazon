class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_categories
  before_action :cart

  private
  def set_categories
    @categories = Category.sort_by_name
  end

  def cart
    @cart = session[:cart]
    @cart_total = @cart.count if session[:cart]
  end

end
