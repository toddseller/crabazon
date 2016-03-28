class OrdersController < ApplicationController
  def index
    @orders = Order.where(user_id: current_user)
    @user = current_user
  end

  def new
    @order = Order.new
  end

  def show
    @order = Order.find(params[:id])
    p 'FUCK!!!!!!!!!'
    p @order.products
  end

  def create
    cart = session[:cart]
    @order = Order.create(user_id: current_user.id, total: session[:cart_total], order_date: Time.now)
    @total = session[:cart_total]
    p '*' * 25
    @user = current_user
    cart.each do |product_id , quantity |
      test = OrdersProduct.new(product_id: product_id.to_i, order_id: @order.id, quantity:  quantity)
      removeStock(product_id.to_i, quantity) if test.save
    end
    UserMailer.order_email(@order, @user).deliver_now
    session[:cart] = {}
    session[:cart_total] = 0
    if request.xhr?
      response = { id: @order.id }
      respond_to do |format|
        format.json { render json: response }
      end
    else
      redirect_to @order
    end
  end

  def removeStock(product_id, quantity)
    @product = Product.find(product_id)
    @product.quantity -= quantity
    @product.save

  end


  private
  def order_params
    params.require(:order).permit(:name, :description, :price, :quantity, :product_image, { category_ids: [] })
  end
end
