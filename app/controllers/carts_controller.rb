class CartsController < ApplicationController

  def remove
    product_data = session[:cart]
    product_id = params[:product_id]
    session[:cart].delete(product_id)

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
    response = { cart: @cart, cart_total: @cart_total}
    if request.xhr?
      respond_to do |format|
        format.json { render json: response}
      end
    else
      redirect_to '/'
    end
  end

  def update_cart
    #loop through cart by index and update with searalized numbers 
    all_product_quantities  = params[:all_product_quantities]
    product_data = session[:cart]
    product_data.each_with_index do |product, index|
      session[:cart][product[0]] = all_product_quantities["#{index}"]["value"].to_i 
    end
    redirect_to '/orders'
    
  end


  private

  def build_cart(product_data)
    cart = Product.find(product_data.keys).map(&:attributes)
    cart.each { |product| product['quantity'] = product_data[product['id'].to_s] }
  end

  def calculate_cart(product_data)
    cart = Product.find(product_data.keys).map(&:attributes)
    cart_total = 0
    cart.each do |product|
      product_id = product["id"]
      total = (product["price"] * product_data[product_id.to_s])
      cart_total += total
    end
      cart_total
  end 

end


