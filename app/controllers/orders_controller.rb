class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = Order.where(user_id: current_user)
    @user = current_user
  end

  def new
    @order = Order.new
  end

  def show
    @order = current_user.orders.find_by(id: params[:id])
    redirect_to orders_path, alert: 'Order not found.' unless @order
  end

  def create
    cart = session[:cart] || {}
    order = nil
    error = nil
    Order.transaction do
      # locked in id order so concurrent checkouts can't oversell or deadlock
      products = Product.lock.where(id: cart.keys).order(:id).index_by { |product| product.id.to_s }
      error = checkout_error(cart, products)
      next if error

      order = Order.create!(user: current_user, order_date: Time.now, total: cart.sum { |id, quantity| products[id].price * quantity })
      cart.each do |id, quantity|
        OrdersProduct.create!(order: order, product: products[id], quantity: quantity)
        products[id].decrement!(:quantity, quantity)
      end
    end
    return refuse(error, '/orders/new') if error

    session[:cart] = {}
    session[:cart_total] = 0
    begin
      UserMailer.order_email(order, current_user).deliver_now
    rescue StandardError => e
      # the order is placed; an error page here would only invite a second, duplicate checkout
      logger.error("Order #{order.id} confirmation email failed: #{e.class}: #{e.message}")
    end
    if request.xhr?
      render json: { id: order.id }
    else
      redirect_to order
    end
  end

  private
  def checkout_error(cart, products)
    return 'Your cart is empty.' if cart.empty?
    cart.each do |id, quantity|
      product = products[id]
      return 'A product in your cart is no longer for sale.' unless product
      return "#{product.name}: only #{product.quantity} in stock." unless quantity.between?(1, product.quantity)
    end
    nil
  end

  def order_params
    params.require(:order).permit(:name, :description, :price, :quantity, :product_image, { category_ids: [] })
  end
end
