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
    if !session[:cart]
      session[:cart] = {}
    end
    product_data = session[:cart]
    product_data[product_id] ? product_data[product_id] += 1 : product_data[product_id] = 1

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
    #loop through cart by index and update with searalized numbers
    product_id = params[:id]
    product_quantities  = params[:product_quantities]
    product_data = session[:cart]
    test = product_data.select { |k,v| k == product_id }

    session[:cart][product_id] = product_quantities.to_i
    @cart = build_cart(test)
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


