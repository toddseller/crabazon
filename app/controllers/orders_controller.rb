class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def show
    render 'show'
  end

  def create
    cart = session[:cart]
    @order = Order.create(user_id: session[:id])


    cart.each do |product_id , quantity |
      OrdersProduct.new(product_id: product_id.to_i, quantity:  quantity)
      removeStock(product_id.to_i, quantity)
    end
    session[:cart] = {}
    session[:cart_total] = 0
    redirect_to "/orders/#{@order.id}" #this is not working bitch d
  end

  def removeStock(product_id, quantity)
    @product = Product.find(product_id)
    p "SHIT IS COOL ========="
    p @product.quantity
    p quantity
    @product.quantity -= quantity
    p @product.quantity
  end


  private
  def order_params
    params.require(:order).permit(:name, :description, :price, :quantity, :product_image, { category_ids: [] })
  end
end
