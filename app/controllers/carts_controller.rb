class CartsController < ApplicationController

  def remove
    product_data = session[:cart]
    product_id = params[:product_id]
    test = session[:cart].delete(product_id)
    p session[:cart]
    p '-' * 25
    p product_data
    @cart = build_cart(product_data)
    @cart_total = calculate_cart(product_data)
    response = { cart: @cart, cart_total: @cart_total}
    if request.xhr?
      respond_to do |format|
        format.json { render json: response}
      end
    else
      redirect_to '/'
    end
  end

  #Index shows all cart
  def show
      # @products = cart_session.cart_contents
  end

  #Add
  def add
    product_id = params[:product_id]
    session[:cart] ||= {}
    product_data = session[:cart]
    quantity = product_data[product_id].to_i + 1
    product = Product.find(product_id)
    return refuse_quantity(product, '/') unless quantity_in_stock?(product, quantity)
    product_data[product_id] = quantity

    @cart = build_cart(product_data)
    @cart_total = calculate_cart(product_data)
    @quantity_available = calculate_quantity_available(product_id)
    response = { cart: @cart, cart_total: @cart_total, quantity_available: @quantity_available}
    if request.xhr?
      respond_to do |format|
        format.json { render json: response }
      end
    else
      redirect_to '/'
    end
  end

  def calculate_quantity_available(product_id)
    quantity_left = Product.find(product_id).quantity - session[:cart][product_id].to_i

  end

  def update_cart
    product_id = params[:id]
    product = Product.find(product_id)
    quantity = Integer(params[:product_quantities].to_s, 10, exception: false)
    return refuse_quantity(product, '/orders/new') unless quantity_in_stock?(product, quantity)
    product_data = session[:cart]
    product_data[product_id] = quantity
    @cart = build_cart(product_data.slice(product_id))
    @cart_total = calculate_cart(product_data)
    response = { cart: @cart, cart_total: @cart_total }
    if request.xhr?
      respond_to do |format|
        format.json { render json: response }
      end
    else
      redirect_to '/orders'
    end
  end


  private

  def quantity_in_stock?(product, quantity)
    quantity.is_a?(Integer) && quantity.between?(1, product.quantity)
  end

  def refuse_quantity(product, path)
    refuse("#{product.name}: choose a quantity from 1 to #{product.quantity}.", path)
  end

  def build_item(product)
    cart = Product.find(product)
  end

  def build_cart(product_data)
    cart = Product.find(product_data.keys).map(&:attributes)
    cart.each { |product| product['cart_quantity'] = product_data[product['id'].to_s] }
  end

  def calculate_cart(product_data)
    cart = Product.find(product_data.keys).map(&:attributes)
    cart_total = 0
    cart.each do |product|
      product_id = product["id"]
      total = (product["price"] * product_data[product_id.to_s])
      cart_total += total
    end
    session[:cart_total] = cart_total
    return cart_total

  end

end


