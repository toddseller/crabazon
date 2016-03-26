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
        cart = session[:cart]
        # if cart.has_key?(:product_id)
            p "***********************"
            p cart[:product_id]
            # cart[:product_id] = cart[:product_id] + 1
        # else
            cart << {product: product_id, quantity: 1}
        # end

        p "?????????????????"   
        # p cart
        redirect_to '/'
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


