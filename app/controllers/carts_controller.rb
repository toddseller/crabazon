class CartsController < ApplicationController

    def new
        
    end
    #Index shows all cart 
    def show
        @products = cart_session.cart_contents
    end

    #Add
    def update
        session[:cart] ||={}
        products = session[:cart][:products]

        #If exists, add new, else create new variable
        if (products && products != {})
            session[:cart][:products] << params[:id]
        else
            session[:cart][:products] = Array(params[:id])
        end

        #Handle the request
        respond_to do |format|
            format.json { render json: cart_session.build_json }
            format.html { redirect_to cart_index_path }
        end
    end

    #Delete
    def remove
        session[:cart] ||={}
        products = session[:cart][:products]
        id = params[:id]
        all = params[:all]

        #Is ID present?
        unless id.blank?
            unless all.blank?
                products.delete(params['id'])
            else
                products.delete_at(products.index(id) || products.length)
            end
        else
            products.delete
        end

        #Handle the request
        respond_to do |format|
            format.json { render json: cart_session.build_json }
            format.html { redirect_to cart_index_path }
        end
    end

end


