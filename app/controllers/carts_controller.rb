class CartsController < ApplicationController

  # def new
  #     session[:cart] = []
  # end
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

      product_data[:product_id]
      product_data[product_id] ? product_data[product_id] += 1 : product_data[product_id] = 1

      @cart = build_cart(product_data)
      if request.xhr?
        respond_to do |format|
          format.json { render json: @cart.to_json }
        end
      else
        redirect_to '/'
      end
  end

  private

  def build_cart(product_data)
    cart = Product.find(product_data.keys).map(&:attributes)
    cart.each { |product| product['quantity'] = product_data[product['id'].to_s] }
  end 

  # #Delete
  # def remove
  #     session[:cart] ||={}
  #     products = session[:cart][:products]
  #     id = params[:id]
  #     all = params[:all]

  #     #Is ID present?
  #     unless id.blank?
  #         unless all.blank?
  #             products.delete(params['id'])
  #         else
  #             products.delete_at(products.index(id) || products.length)
  #         end
  #     else
  #         products.delete
  #     end

  #     #Handle the request
  #     respond_to do |format|
  #         format.json { render json: cart_session.build_json }
  #         format.html { redirect_to cart_index_path }
  #     end
  # end

end


