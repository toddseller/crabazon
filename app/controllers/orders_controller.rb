class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    p "hey girl ==============="
    p cart = session[:cart]
    @order = Order.new(user_id: session[:id])

    cart.each do |product_id , quantity |
      OrdersProduct.new(product_id: product_id.to_i, quantity:  quantity)
      removeStock(product_id, quantity)
    end
    redirect '/orders/#{:id}'

  end

  def removeStock(product_id, quanity)
    @product = product.find(product_id)
    @product.quantity -= quantity
  end


  private
  def order_params
    params.require(:order).permit(:name, :description, :price, :quantity, :product_image, { category_ids: [] })
  end
end
