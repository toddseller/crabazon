class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = Order.new
  end

  private
  def order_params
    params.require(:order).permit(:name, :description, :price, :quantity, :product_image, { category_ids: [] })
  end
end
